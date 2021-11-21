import Vapor

func routes(_ app: Application) throws {
    let ecnuServices = app.grouped("ecnu-service")
    
    ecnuServices.get("course-calendar") { req -> Response in
        struct CourseCalendarQuery: Content, Validatable {
            let username: String
            let password: String
            let year: Int
            let semesterIndex: SemesterIndex

            static func validations(_ validations: inout Validations) {
                validations.add("username", as: String.self, is: .count(11...11) && .characterSet(.decimalDigits))
                validations.add("year", as: Int.self, is: .in(开学日期.keys.map { Int($0)! }.sorted()))
            }
        }

        try CourseCalendarQuery.validate(query: req)
        let query = try req.query.decode(CourseCalendarQuery.self)

        let calendarResult = CourseService(username: query.username, password: query.password, year: query.year, semesterIndex: query.semesterIndex.rawValue)
            .getCourseCalendar()

        if calendarResult.code == .成功 {
            var header = HTTPHeaders()
            header.contentType = .fileExtension("ics")
            // Vapor doesn't support `filename*` now.
            header.add(name: "Content-Disposition",
                       value: "attachment;filename*=utf-8''\(calendarResult.data["fileName"]!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")
            let response = Response(headers: header,
                                    body: .init(string: calendarResult.data["content"]!))

            return response
        }

        var header = HTTPHeaders()
        header.contentType = .json
        header.add(name: "Content-Encoding",
                   value: "utf-8")

        return Response(headers: header, body: .init(data: (calendarResult.toJSONString() ?? calendarResult.message).data(using: .utf8)!))
    }
}
