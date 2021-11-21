//
//  LibecnuService.swift
//  Whiteboard
//
//  Created by 陈俊杰 on 2020/9/12.
//

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
import Kanna

class LibecnuService {
    internal let urlSession: URLSession
    
    internal let username: String
    internal let password: String
    
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
    
    private var _loginResult: LibecnuLoginStatus?
    
    /// This is a computed property. Once we access this property for the first time,
    /// it will automatically try to login and then return the result.
    internal var loginResult: LibecnuLoginStatus {
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
    
    internal func login() -> LibecnuLoginStatus {
        let loginResult = _login()
        return loginResult
    }
}


extension LibecnuService {
    fileprivate func _login() -> LibecnuLoginStatus {
        var status: LibecnuLoginStatus = .未知登录错误
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let parameter = "?extpatid=\(username)&extpatpw=\(password)"
        
        if let urlStr = (LIBECNU_LOGIN_URL + parameter).addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed), let url = URL(string: urlStr) {
            let request = URLRequest(url: url)
            urlSession.dataTask(with: request) {
                data, _, _ in
                defer { semaphore.signal() }
                if let data = data, let content = String(data: data, encoding: .utf8) {
                    if let doc = try? HTML(html: content, encoding: .utf8) {
                        let matchedErr = doc.xpath("/html/body/div[2]/div[2]/div[1]/form/table/tr[2]/td/text()")
                        for i in 0..<matchedErr.count {
                            if matchedErr[i].text!.contains("无法通过您的校园卡确定您的身份") {
                                status = .用户名密码错误
                                return
                            }
                        }
                        
                        status = .登录成功
                        self._realName = doc.xpath("//*[@id=\"ECNU_pageNavColumn\"]/table/tr/td[1]/div/strong/text()").first?.text
                        return
                    }
                }
            }.resume()
            
            semaphore.wait()
        }
        
        return status
    }
}
