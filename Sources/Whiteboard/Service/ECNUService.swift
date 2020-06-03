//
//  ECNUService.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

#if canImport(JavaScriptCore)
import JavaScriptCore
#endif

import Kanna
import PerfectMySQL

class ECNUService {
    internal let urlSession: URLSession
    
    internal let username: String
    internal let password: String?
    
    /// It will be initialized during login process.
    internal var rsa: String?
    
    /// It will be initialized during login process.
    internal var passwordLength: Int?
    
//    private var _realName: String?
//
//    internal var realName: String {
//        get {
//            _realName ?? username
//        }
//        set {
//            _realName = newValue
//        }
//    }
    
    private var _loginResult: LoginStatus?
    
    /// This is a computed property. Once we access this property for the first time,
    /// it will automatically try to login and then return the result.
    internal var loginResult: LoginStatus {
        if let loginResult = _loginResult {
            return loginResult
        } else {
            _loginResult = login()
            return _loginResult!
        }
    }
    
    internal var isUserInfoSaveSuccess: Bool = false
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        
        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.httpAdditionalHeaders = ["Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8"]
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    init(username: String, rsa: String, passwordLength: Int) {
        self.username = username
        self.rsa = rsa
        self.passwordLength = passwordLength
        self.password = nil

        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.httpAdditionalHeaders = ["Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8"]
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    internal func login() -> LoginStatus {
        let loginResult = _login()
        switch loginResult {
        case .成功, .用户名密码错误:
            return loginResult
        case .未知错误, .验证码有误:
            // Try again.
            return _login()
        }
    }
}

// MARK: - Login Service

extension ECNUService {
    /// Recognize the captcha via Python script.
    ///
    /// We don't import any swift tesseract module right now, so we
    /// do recognize job via Python.
    fileprivate func getCaptcha() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        
        /// Save Captacha to file system.
        var code = "8888"
        
        let request = URLRequest(url: URL(string: CAPTCHA_URL)!)
        urlSession.dataTask(with: request) {
            data, _, error in
            defer { semaphore.signal() }
            
            do {
                let path = CAPTCHA_PATH // 取一个随机名
                let captchaURL = URL(fileURLWithPath: path)
                
                try data!.write(to: captchaURL)
                
                code = String(runCommand(launchPath: TESSERACT_PATH, arguments: [path, "stdout"]).prefix(4))
                
                /// 删除已经识别的验证码
                let fileManager = FileManager.default
                try fileManager.removeItem(at: captchaURL)
            } catch {
                fatalError("\(error)")
            }
        }.resume()
        
        semaphore.wait()
        
        return code
    }
    
    /// Calculate rsa value via Python script
    ///
    /// We don't have JavaScript library for Swift on Linux now.
    /// So we do this via Python script if os(Linux), otherwise, use JavaScriptCore.
    fileprivate func getRSA() -> String {
//        #if !os(Linux)
//        let context: JSContext = JSContext()
//        context.evaluateScript(desCode)
//
//        let squareFunc = context.objectForKeyedSubscript("strEnc")
//
//        let rsa = squareFunc?.call(withArguments: [username + password!, "1", "2", "3"]).toString() ?? ""
//
//        return rsa
//
//        #else
        let rsa = runCommand(launchPath: NODE_PATH,
                             arguments: [JS_FILE_PATH, username + password!])
        
        return rsa
//        #endif
    }
    
    fileprivate func _login() -> LoginStatus {
        let semaphore = DispatchSemaphore(value: 0)
        let semaphore1 = DispatchSemaphore(value: 0)
        let semaphore2 = DispatchSemaphore(value: 0)
        
        var request = URLRequest(url: URL(string: PORTAL_URL)!)
        urlSession.dataTask(with: request) {
            _, _, _ in
            defer { semaphore1.signal() }
        }.resume()
        
        DispatchQueue.global().async {
            defer { semaphore2.signal() }
            if let password = self.password {
                self.passwordLength = password.count
                self.rsa = self.getRSA()
            }
        }
        
        semaphore1.wait()
        let code = getCaptcha()
        semaphore2.wait()
        let postData: [String: String] = [
            "code": String(code),
            "rsa": rsa ?? "",
            "ul": String(username.count),
            "pl": "\(passwordLength ?? 0)",
            "lt": "LT-1665926-4VCedaEUwbuDuAPI7sKSRACHmInAcl-cas",
            "execution": "e1s1",
            "_eventId": "submit"
        ]
        
        var status: LoginStatus?
        
        request = URLRequest(url: URL(string: PORTAL_URL)!)
        request.encodeParameters(parameters: postData)
        
        urlSession.dataTask(with: request) {
            data, _, _ in
            defer { semaphore.signal() }
            if let data = data, let content = String(data: data, encoding: .utf8) {
                if let doc = try? HTML(html: content, encoding: .utf8) {
                    for err in doc.xpath("//*[@id='errormsg']") {
                        switch err.text {
                        case "用户名密码错误":
                            status = LoginStatus.用户名密码错误
                        case "验证码有误":
                            status = LoginStatus.验证码有误
                        default:
                            status = LoginStatus.未知错误
                        }
                        return
                    }
//                    if let realName = doc.xpath("//a[contains(@title, \"查看登录记录\")]/font/text()").first?.text {
//                        self.realName = realName
//                    }
                    status = LoginStatus.成功
                    self.isUserInfoSaveSuccess = MySQLConnector.updateUser(schoolID: self.username,
                                                                           rsa: self.rsa!,
                                                                           passwordLength: self.passwordLength!)
                } else {
                    status = LoginStatus.未知错误
                }
            } else {
                status = LoginStatus.未知错误
            }
        }.resume()
        
        semaphore.wait()
        if let status = status {
            return status
        } else {
            return LoginStatus.未知错误
        }
    }
}
