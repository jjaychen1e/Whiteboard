//
//  LibecnuLoginStatus.swift
//  Whiteboard
//
//  Created by 陈俊杰 on 2020/9/12.
//

import Foundation

enum LibecnuLoginStatus: Int {
    case 登录成功 = 0
    case 用户名密码错误 = 1
    case 未知登录错误 = 2

    func toString() -> String {
        switch self {
        case .登录成功:
            return "登录成功"
        case .用户名密码错误:
            return "用户名密码错误"
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
        case .未知登录错误:
            return .出错
        }
    }
}
