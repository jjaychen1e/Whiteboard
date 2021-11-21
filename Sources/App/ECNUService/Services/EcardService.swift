//
//  EcardService.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/6/15.
//

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
import Kanna

class EcardService {
    internal let urlSession: URLSession
    
    internal let username: String
    internal let password: String
    private var encrypedPassword: String {
        (password.data(using: .utf8)?.base64EncodedString())!
    }
    
    private var _realName: String?
    
    internal var realName: String? {
        if _realName != nil {
            return _realName
        } else if loginResult == .登录成功 {
            return _realName
        } else {
            return nil
        }
    }
    
    private var _loginResult: EcardLoginStatus?
    
    /// This is a computed property. Once we access this property for the first time,
    /// it will automatically try to login and then return the result.
    internal var loginResult: EcardLoginStatus {
        if let loginResult = _loginResult {
            return loginResult
        } else {
            _loginResult = login()
            return _loginResult!
        }
    }
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        
        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.httpAdditionalHeaders = ["Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8"]
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    internal func login() -> EcardLoginStatus {
        let loginResult = _login()
        switch loginResult {
        case .登录成功, .用户名密码错误, .未知登录错误:
            return loginResult
        case .验证码有误:
            // Dangerous..
            return login()
        }
    }
}

extension EcardService {
    fileprivate func _login() -> EcardLoginStatus {
        var status: EcardLoginStatus = .未知登录错误
        
        defer{
            LogManager.saveProcessLog(message: "\(username) \(_realName ?? "") \(status.toString())")
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var code = getCaptcha()
        while code.count < 4 {
            code = getCaptcha()
        }
        
        let postData: [String: String] = [
            "username": username,
            "password": encrypedPassword,
            "code": code
        ]
        
        var request = URLRequest(url: URL(string: ECARD_PORTAL_URL)!)
        request = URLRequest(url: URL(string: ECARD_PORTAL_URL)!)
        request.encodeParameters(parameters: postData)
        
        urlSession.dataTask(with: request) {
            data, _, _ in
            defer { semaphore.signal() }
            if let data = data, let content = String(data: data, encoding: .utf8) {
                if let doc = try? HTML(html: content, encoding: .utf8) {
                    if let err = doc.xpath("//*[@id=\"msg\"]/text()").first?.text {
                        switch err {
                        case "验证码有误":
                            status = .验证码有误
                        case "密码错误", "账号不存在":
                            status = .用户名密码错误
                        default:
                            status = .未知登录错误
                        }
                        return
                    }
                    status = .登录成功
                    self._realName = doc.xpath("/html/body/div[3]/div/div/div[2]/p[1]/text()").first?.text
                    return
                }
            }
        }.resume()
        
        semaphore.wait()
        
        return status
    }
    
    /// Recognize the captcha via tesseract
    fileprivate func getCaptcha() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        
        /// Save Captacha to file system.
        var code = "8888"
        
        let request = URLRequest(url: URL(string: ECARD_CAPTCHA_URL)!)
        urlSession.dataTask(with: request) {
            data, _, error in
            defer { semaphore.signal() }
            
            do {
                let path = CAPTCHA_PATH // 取一个随机名
                let captchaURL = URL(fileURLWithPath: path)
                
                try data!.write(to: captchaURL)
                
                // Preprocess
                try! CommandLineInterface.runCommand(CONVERT_PATH, arguments: [path, "-compress", "none", "-alpha", "off", "-depth", "8", "-threshold", "50%", path])
                code = String(try! CommandLineInterface.runCommand(TESSERACT_PATH, arguments: [path, "stdout", "--dpi", "159", "--psm", "7", "captcha"])
                    .filter { (char) -> Bool in
                        char.isNumber
                }.prefix(4))
                
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
}
