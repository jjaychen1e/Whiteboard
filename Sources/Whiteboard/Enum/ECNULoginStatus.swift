//
//  LoginStatus.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

enum ECNULoginStatus: Int {
    case 登录成功 = 0
//    case 用户名密码错误 = 1
//    case 验证码有误 = 2
//    case 未知错误 = 3
    case 登录失败 = 4

    func toString() -> String {
        switch self {
        case .登录成功:
            return "登录成功"
        case .登录失败:
            return "登录失败"
        }
    }

    func toResultCode() -> ResultCode {
        switch self {
        case .登录成功:
            return .成功
        case .登录失败:
            return .登录失败
        }
    }
}
