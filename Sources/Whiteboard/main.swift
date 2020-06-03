import Foundation
import PerfectHTTP
import PerfectHTTPServer

let PORT = 8181
let HOST_NAME = "localhost:\(PORT)"

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/ecnu-service/course-list") {
    request, response in
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
            try! response.setBody(json: ResultEntity.fail(code: .学年或学期索引不正确))
            response.completed()
            return
        }
        
        let result = CourseService(username: username, password: password, year: year, semesterIndex: semesterIndex).getCourseList()
        
        try! response.setBody(json: result)
        response.completed()
        
        return
    }
    
    try! response.setBody(json: ResultEntity.fail(code: .参数匹配失败))
    response.completed()
    return
}

routes.add(method: .get, uri: "/ecnu-service/lesson-list") {
    request, response in
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
            try! response.setBody(json: ResultEntity.fail(code: .学年或学期索引不正确))
            response.completed()
            return
        }
        
        let result = CourseService(username: username, password: password, year: year, semesterIndex: semesterIndex)
            .getLessonList()
        
        try! response.setBody(json: result)
        response.completed()
        
        return
    }
    
    try! response.setBody(json: ResultEntity.fail(code: .参数匹配失败))
    response.completed()
    return
}

routes.add(method: .get, uri: "/ecnu-service/deadline-list") {
    request, response in
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password"),
        let startTimestamp = request.param(name: "startTimestamp"),
        let endTimestamp = request.param(name: "endTimestamp") {
        let result = ElearningService(username: username, password: password)
            .getDeadlineList(startTimestamp: startTimestamp, endTimestamp: endTimestamp)
        
        try! response.setBody(json: result)
        response.completed()
        return
    }
    
    try! response.setBody(json: ResultEntity.fail(code: .参数匹配失败))
    response.completed()
    return
}

routes.add(method: .get, uri: "/ecnu-service/deadline-calendar") {
    request, response in
    
    if let username = request.param(name: "username"),
        let password = request.param(name: "password") {
        let result = ElearningService(username: username, password: password).generateDeadlineCalendarID()
        if let calendarID = result.calendarID {
            response.status = .movedPermanently
            response.setHeader(.location, value: "webcal://\(HOST_NAME)/ecnu-service/deadline-calendar-feed/\(calendarID)")
            response.completed()
            return
        }
        try! response.setBody(json: ResultEntity.fail(code: result.code))
        response.completed()
    }
    try! response.setBody(json: ResultEntity.fail(code: .参数匹配失败))
    response.completed()
}

routes.add(method: .get, uri: "/ecnu-service/deadline-calendar-feed/{calendarID}") {
    request, response in
    response.setHeader(.contentEncoding, value: "utf-8")
    response.setHeader(.contentType, value: "application/json;charset=utf-8")
    
    if let calendarID = request.urlVariables["calendarID"] {
        let queryResult = MySQLConnector.queryUserInfo(calendarID: calendarID)
        if queryResult.isSuccess {
            let calendarResult = ElearningService(username: queryResult.username, rsa: queryResult.rsa, passwordLength: queryResult.passwordLength)
                .getDeadlineCalendar()
            if calendarResult.code == .成功, let data = calendarResult.data as? [String: String] {
                response.setHeader(.contentType, value: "text/calendar;charset=utf-8")
                response.setHeader(.contentDisposition,
                                   value: "attachment; filename=\"\(data["fileName"]!)\"")
                response.setBody(string: data["content"]!)
                response.completed()
                return
            }
        }
    }
    
    try! response.setBody(json: ResultEntity.fail(code: .出错))
    response.completed()
}

do {
    try FileManager.default.createDirectory(atPath: FileManager.default.currentDirectoryPath + "/tmp", withIntermediateDirectories: true, attributes: nil)
    
    generateHelperJS()
    
    // Launch the HTTP server.
    try HTTPServer.launch(
        .server(name: HOST_NAME, port: PORT, routes: routes))
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}
