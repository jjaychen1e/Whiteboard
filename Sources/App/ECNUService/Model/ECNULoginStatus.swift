//
//  LoginStatus.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

enum ECNULoginStatus: Int {
    case 登录成功 = 0
    case 用户名密码错误 = 1
    case 验证码有误 = 2
    case 未知错误 = 3
//    case 登录失败 = 4
    case 账号被锁定一分钟 = 5

    func toString() -> String {
        switch self {
        case .登录成功:
            return "登录成功"
        case .用户名密码错误:
            return "用户名密码错误"
        case .验证码有误:
            return "自动识别验证码有误，请重试"
        case .未知错误:
            return "未知错误"
        case .账号被锁定一分钟:
            return "登录失败次数过多，账号被锁定一分钟"
        }
    }

    func toResultCode() -> ResultCode {
        switch self {
        case .登录成功:
            return .成功
        case .未知错误:
            return .出错
        case .用户名密码错误:
            return .用户名密码错误
        case .验证码有误:
            return .验证码有误
        case .账号被锁定一分钟:
            return .账号被锁定一分钟
        }
    }
}
