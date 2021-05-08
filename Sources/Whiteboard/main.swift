import Foundation
import PerfectHTTP
import PerfectHTTPServer

let PORT = 8181
let DOMAIN_NAME = "application.jjaychen.me"
let HOST_NAME = "localhost:\(PORT)"

// Register your own routes and handlers
var routes = Routes()

routes.add(method: .get, uri: "/ecnu-service/login-verify") {
    request, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password") {
        let service = LibecnuService(username: username, password: password)
        switch service.loginResult {
        case .登录成功:
            response.setBody(string: ResultEntity.success(message: service.realName ?? "", data: true).toJSONString() ?? "")
        case .用户名密码错误:
            response.setBody(string: ResultEntity.fail(code: .用户名密码错误, data: false).toJSONString() ?? "")
        default:
            response.setBody(string: ResultEntity.fail(code: .出错, data: false).toJSONString() ?? "")
        }
    } else {
        response.setBody(string: ResultEntity.fail(code: .参数匹配失败, data: false).toJSONString() ?? "")
    }
    
    response.completed()
}

routes.add(method: .get, uri: "/ecnu-service/real-name") {
    request, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password") {
        let service = EcardService(username: username, password: password)
        if let realName =  service.realName {
            response.setBody(string: ResultEntity.success(data: realName).toJSONString() ?? "")
        } else {
            response.setBody(string: ResultEntity.fail(code: service.loginResult.toResultCode(), data: "").toJSONString() ?? "")
        }
    } else {
        response.setBody(string: ResultEntity.fail(code: .参数匹配失败, data: "").toJSONString() ?? "")
    }
    
    response.completed()
}

routes.add(method: .get, uri: "/ecnu-service/course-list") {
    request, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password"),
        let _year = request.param(name: "year"),
        let _semesterIndex = request.param(name: "semesterIndex"),
        let year = Int(_year),
        let semesterIndex = Int(_semesterIndex) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = Int(dateFormatter.string(from: Date()))!
        
        guard (1...3).contains(semesterIndex), (2019...currentYear).contains(year) else {
            response.setBody(string: ResultEntity.fail(code: .学年或学期索引不正确, data: "").toJSONString() ?? "")
            response.completed()
            return
        }
        
        let result = CourseService(username: username, password: password, year: year, semesterIndex: semesterIndex).getCourseList()
        
        response.setBody(string: result.toJSONString() ?? "")
        response.completed()
        
        return
    }
    
    response.setBody(string: ResultEntity.fail(code: .参数匹配失败, data: "").toJSONString() ?? "")
    response.completed()
    return
}

routes.add(method: .get, uri: "/ecnu-service/lesson-list") {
    request, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password"),
        let _year = request.param(name: "year"),
        let _semesterIndex = request.param(name: "semesterIndex"),
        let year = Int(_year),
        let semesterIndex = Int(_semesterIndex) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = Int(dateFormatter.string(from: Date()))!
        
        guard (1...3).contains(semesterIndex), (2019...currentYear).contains(year) else {
            response.setBody(string: ResultEntity.fail(code: .学年或学期索引不正确, data: "").toJSONString() ?? "")
            response.completed()
            return
        }
        
        let result = CourseService(username: username, password: password, year: year, semesterIndex: semesterIndex)
            .getLessonList()
        
        response.setBody(string: result.toJSONString() ?? "")
        response.completed()
        
        return
    }
    
    response.setBody(string: ResultEntity.fail(code: .参数匹配失败, data: "").toJSONString() ?? "")
    response.completed()
    return
}

routes.add(method: .get, uri: "/ecnu-service/course-calendar") {
    request, response in
    LogManager.saveProcessLog(message: "Receive request `course-calendar` with username \(request.param(name: "username") ?? "nil")")
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password"),
        let _year = request.param(name: "year"),
        let _semesterIndex = request.param(name: "semesterIndex"),
        let year = Int(_year),
        let semesterIndex = Int(_semesterIndex) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = Int(dateFormatter.string(from: Date()))!
        
        guard (1...3).contains(semesterIndex), (2019...currentYear).contains(year) else {
            response.setBody(string: ResultEntity.fail(code: .学年或学期索引不正确, data: "").toJSONString() ?? "")
            response.completed()
            return
        }
        
        let calendarResult = CourseService(username: username, password: password, year: year, semesterIndex: semesterIndex)
            .getCourseCalendar()
        
        if calendarResult.code == .成功 {
            response.setHeader(.contentType, value: "text/calendar;charset=utf-8")
            response.setHeader(.contentDisposition,
                               value: "attachment; filename=\"\(calendarResult.data["fileName"]!)\"")
            response.setBody(string: calendarResult.data["content"]!)
            response.completed()
            return
        }
        response.setBody(string: calendarResult.toJSONString() ?? "")
        response.completed()
    }
    
    response.setBody(string: ResultEntity.fail(code: .出错, data: "").toJSONString() ?? "")
    response.completed()
}

routes.add(method: .get, uri: "/ecnu-service/deadline-list") {
    request, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password"),
        let startTimestamp = request.param(name: "startTimestamp"),
        let endTimestamp = request.param(name: "endTimestamp") {
        let result = ElearningService(username: username, password: password)
            .getDeadlineList(startTimestamp: startTimestamp, endTimestamp: endTimestamp)
        
        response.setBody(string: result.toJSONString() ?? "")
        response.completed()
        return
    }
    
    response.setBody(string: ResultEntity.fail(code: .参数匹配失败, data: "").toJSONString() ?? "")
    response.completed()
    return
}

routes.add(method: .get, uri: "/ecnu-service/deadline-calendar") {
    request, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    if let username = request.param(name: "username"),
        let password = request.param(name: "password") {
        let result = ElearningService(username: username, password: password).generateDeadlineCalendarID()
        if let calendarID = result.calendarID {
            response.status = .movedPermanently
            response.setHeader(.location, value: "webcal://\(DOMAIN_NAME)/ecnu-service/deadline-calendar-feed/\(calendarID)")
            response.completed()
            LogManager.saveProcessLog(message: "\(username) 创建了日历订阅.")
            return
        }
        response.setHeader(.contentEncoding, value: "utf-8")
        response.setHeader(.contentType, value: "application/json;charset=utf-8")
        response.setBody(string: ResultEntity.fail(code: result.code, data: "").toJSONString() ?? "")
        response.completed()
        return
    }
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    response.setBody(string: ResultEntity.fail(code: .参数匹配失败, data: "").toJSONString() ?? "")
    response.completed()
}

routes.add(method: .get, uri: "/ecnu-service/deadline-calendar-feed/{calendarID}") {
    request, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let calendarID = request.urlVariables["calendarID"] {
        let queryResult = MySQLConnector.queryUserInfo(uuid: calendarID)
        if queryResult.isSuccess {
            let calendarResult = ElearningService(username: queryResult.username, rsa: queryResult.rsa, passwordLength: queryResult.passwordLength)
                .getDeadlineCalendar()
            if calendarResult.code == .成功 {
                LogManager.saveProcessLog(message: "\(queryResult.username) 成功更新了日历")
                response.setHeader(.contentType, value: "text/calendar;charset=utf-8")
                response.setHeader(.contentDisposition,
                                   value: "attachment; filename=\"\(calendarResult.data["fileName"]!)\"")
                response.setBody(string: calendarResult.data["content"]!)
                response.completed()
                return
            } else {
                LogManager.saveProcessLog(message: "\(queryResult.username) 更新日历失败")
            }
        }
    }
    
    response.setBody(string: ResultEntity.fail(code: .出错, data: "").toJSONString() ?? "")
    response.completed()
}

routes.add(method: .get, uri: "/ecnu-service/semester-dates") {
    _, response in
    response.setHeader(.accessControlAllowOrigin, value: "*")
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    response.setBody(string: ResultEntity.success(data: 开学日期).toJSONString() ?? "")
    response.completed()
}

do {
    try FileManager.default.createDirectory(atPath: FileManager.default.currentDirectoryPath + "/tmp", withIntermediateDirectories: true, attributes: nil)
    
    generateHelperJS()
    initializePath()
    
    // Launch the HTTP server.
    try HTTPServer.launch(
        .server(name: HOST_NAME, port: PORT, routes: routes))
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}
