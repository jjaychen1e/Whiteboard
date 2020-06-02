//
//  LoginStatus.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

enum LoginStatus: Int {
    case 成功 = 0
    case 用户名密码错误 = 1
    case 验证码有误 = 2
    case 未知错误 = 3

    func toString() -> String {
        switch self {
        case .成功:
            return "成功"
        case .未知错误:
            return "未知错误，尝试重新运行"
        case .用户名密码错误:
            return "用户名密码错误"
        case .验证码有误:
            return "验证码有误，尝试重新运行"
        }
    }

    func toResultCode() -> ResultCode {
        switch self {
        case .成功:
            return .成功
        case .用户名密码错误:
            return .用户名密码错误
        default:
            return .未知原因登陆失败
        }
    }
}
