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
    
    internal var realName: String? {
        if loginResult == .登录成功 {
            return getRealname()
        }
        return nil
    }
    
    private var _loginResult: ECNULoginStatus?
    
    /// This is a computed property. Once we access this property for the first time,
    /// it will automatically try to login and then return the result.
    internal var loginResult: ECNULoginStatus {
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
    
    internal func login() -> ECNULoginStatus {
        let loginResult = _login()
        switch loginResult {
        case .登录成功, .账号被锁定一分钟, .用户名密码错误:
            return loginResult
        case .验证码有误, .未知错误:
            // Try again.
            return _login()
        }
    }
}

// MARK: - Login Service

extension ECNUService {
    /// Recognize the captcha via tesseract
    fileprivate func getCaptcha() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        
        /// Save Captacha to file system.
        var code = "8888"
        
        let request = URLRequest(url: URL(string: ECNU_CAPTCHA_URL)!)
        urlSession.dataTask(with: request) {
            data, _, error in
            defer { semaphore.signal() }
            
            do {
                let path = CAPTCHA_PATH // 取一个随机名
                let captchaURL = URL(fileURLWithPath: path)
                
                if let data = data {
                    try data.write(to: captchaURL)

                    code = String(runCommand(launchPath: TESSERACT_PATH, arguments: [path, "stdout", "--dpi", "259", "captcha"]).prefix(4))
                    
                    /// 删除已经识别的验证码
                    let fileManager = FileManager.default
                    try fileManager.removeItem(at: captchaURL)
                }
            } catch {
                fatalError("\(error)")
            }
        }.resume()
        
        semaphore.wait()
        
        return code
    }
    
    /// Calculate rsa value via NodeJS
    fileprivate func getRSA() -> String {
        #if !os(Linux)
        let context: JSContext = JSContext()
        context.evaluateScript(desCode)
        
        let squareFunc = context.objectForKeyedSubscript("strEnc")
        
        let rsa = squareFunc?.call(withArguments: [username + password!, "1", "2", "3"]).toString() ?? ""
        
        return rsa
        
        #else
        let rsa = runCommand(launchPath: NODE_PATH,
                             arguments: [JS_FILE_PATH, username + password!])
        
        return rsa
        #endif
    }
    
    fileprivate func _login() -> ECNULoginStatus {
        var status: ECNULoginStatus = .未知错误
        
        defer{ print("\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)) \(username) \(status.toString())") }
        
        if let password = self.password {
            let libecnuService = LibecnuService(username: self.username, password: password)
            switch libecnuService.loginResult {
            case .登录成功:
                break
            case .用户名密码错误:
                status = .用户名密码错误
                return status
            default:
                return status
            }
        }
        let semaphore = DispatchSemaphore(value: 0)
        let semaphore1 = DispatchSemaphore(value: 0)
        let semaphore2 = DispatchSemaphore(value: 0)
        
        var request = URLRequest(url: URL(string: ECNU_PORTAL_URL)!)
        urlSession.dataTask(with: request) {
            _, _, _ in
            do { semaphore1.signal() }
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
        
        
        request = URLRequest(url: URL(string: ECNU_PORTAL_URL)!)
        request.encodeParameters(parameters: postData)
        
        urlSession.dataTask(with: request) {
            data, _, _ in
            defer { semaphore.signal() }
            if let data = data, let content = String(data: data, encoding: .utf8) {
                guard !content.contains(string: "访问被拒绝") else {
                    status = .账号被锁定一分钟
                    return
                }
                
                if let doc = try? HTML(html: content, encoding: .utf8) {
                    for _ in doc.xpath("//*[@id='errormsg']") {
                        status = .验证码有误
                        return
                    }
                    status = .登录成功
                    self.isUserInfoSaveSuccess = MySQLConnector.updateUser(schoolID: self.username,
                                                                           rsa: self.rsa!,
                                                                           passwordLength: self.passwordLength!)
                    return
                } else {
                    status = .未知错误
                    return
                }
            } else {
                status = .未知错误
                return
            }
        }.resume()
        
        semaphore.wait()
    
        return status
    }
}

// MARK: - User Info Service

extension ECNUService {
    private func getRealname() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var realName: String?
        
        let request = URLRequest(url: URL(string: ECNU_PLAN_PANEL_URL)!)
        urlSession.dataTask(with: request) {
            data, _, _ in
            defer { semaphore.signal() }
            if let data = data, let content = String(data: data, encoding: .utf8) {
                if let doc = try? HTML(html: content, encoding: .utf8) {
                    if let name = doc.xpath("/html/body/table/tr[1]/td[4]/text()").first?.text {
                        realName = name
                    }
                }
            }
        }.resume()
        
        semaphore.wait()
        return realName
    }
}
