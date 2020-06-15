//
//  EcardLoginStatus.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/6/15.
//

import Foundation

enum EcardLoginStatus: Int {
    case 登录成功 = 0
    case 用户名密码错误 = 1
    case 验证码有误 = 2
    case 未知登录错误 = 3

    func toString() -> String {
        switch self {
        case .登录成功:
            return "登录成功"
        case .用户名密码错误:
            return "用户名密码错误"
        case .验证码有误:
            return "验证码有误"
        case .未知登录错误:
            return "未知登录错误"
            
        }
    }

    func toResultCode() -> ResultCode {
        switch self {
        case .登录成功:
            return .成功
        case .用户名密码错误:
            return .用户名密码错误
        case .验证码有误:
            return .登录失败
        case .未知登录错误:
            return .出错
        }
    }
}
