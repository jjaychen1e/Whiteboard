//
//  ResultCode.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

enum ResultCode: Int, Encodable {
    case 出错 = -1
    case 成功 = 0
    
    // MARK: General Errors
    
    case 参数匹配失败 = 0001
    
    // MARK: Login(ECNUService, EcardService)
    
    case 用户名密码错误 = 1002
    case 登录失败 = 1004
    case 数据库保存失败 = 1005
    case 账号被锁定一分钟 = 1006
    
    // MARK: CourseService
    
    case IDS获取失败 = 2001
    case 课程列表为空 = 2002
    case 课程安排为空 = 2003
    case 学年或学期索引不正确 = 2004
    case 学期开学日期未设定 = 2005
    
    // MARK: ElearningService
    
    case 期限任务列表为空 = 3001
    case 日历地址获取失败 = 3002
    
    // MARK: EcardService
    
    case 获取名字失败 = 4001
    
    func toString() -> String {
        switch self {
        case .成功:
            return "成功"
        case .出错:
            return "出错"
        case .参数匹配失败:
            return "参数匹配失败"
        case .用户名密码错误:
            return "用户名密码错误"
        case .登录失败:
            return "登录失败，请检查用户名密码，或请尝试重新请求"
        case .数据库保存失败:
            return "数据库保存失败"
        case .账号被锁定一分钟:
            return "登录失败次数过多，账号被锁定一分钟"
        case .IDS获取失败:
            return "IDS获取失败，请尝试重新请求"
        case .课程列表为空:
            return "课表为空"
        case .课程安排为空:
            return "课程安排为空"
        case .学年或学期索引不正确:
            return "学年或学期索引不正确"
        case .学期开学日期未设定:
            return "学期开学日期未设定"
        case .期限任务列表为空:
            return "期限任务列表为空"
        case .日历地址获取失败:
            return "日历地址获取失败"
        case .获取名字失败:
            return "获取名字失败"
        }
    }
}
