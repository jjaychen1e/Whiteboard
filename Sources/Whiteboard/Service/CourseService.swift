//
//  CourseService.swift
//  COpenSSL
//
//  Created by JJAYCHEN on 2020/5/28.
//

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

class CourseService: ECNUService {
    private let year: Int
    private let semesterIndex: Int
    private var semesterID: String {
        String(801 + (year - 2019) * 96 + (semesterIndex - 1) * 32)
    }
    
    private var _ids: String?
    private var ids: String {
        if let ids = _ids {
            return ids
        } else {
            _ids = getIDS()
            return _ids!
        }
    }
    
    private var _courses: [Course]?
    private var courses: [Course] {
        if let courses = _courses {
            return courses
        } else {
            _courses = getCourses()
            return _courses!
        }
    }
    
    private var _lessons: [Lesson]?
    private var lessons: [Lesson] {
        if let lessons = _lessons {
            return lessons
        } else {
            _lessons = getLessons()
            return _lessons!
        }
    }
    
    private let calendar = Calendar.current
    
    private let semesterBeginDateComp: DateComponents?
    
    internal init(username: String, password: String, year: Int, semesterIndex: Int) {
        self.year = year
        self.semesterIndex = semesterIndex
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        /// 设置开学时间
        if let semesterBeginDate = dateFormatter.date(from: 开学日期[String(year)]![String(semesterIndex)]!) {
            self.semesterBeginDateComp = calendar.dateComponents([.year, .month, .day], from: semesterBeginDate)
        } else {
            self.semesterBeginDateComp = nil
        }
        
        super.init(username: username, password: password)
    }
    
    func getCourseList() -> ResultEntity {
        guard semesterBeginDateComp != nil else {
            return ResultEntity.fail(code: .学期开学日期未设定)
        }
        
        guard loginResult == .成功 else {
            switch loginResult {
            case .用户名密码错误:
                return ResultEntity.fail(code: .用户名密码错误)
            default:
                return ResultEntity.fail(code: .未知原因登陆失败)
            }
        }
        
        guard courses.count > 0 else {
            return ResultEntity.fail(code: .课程列表为空)
        }
        
        return ResultEntity.success(data: courses)
    }
    
    func getLessonList() -> ResultEntity {
        guard semesterBeginDateComp != nil else {
            return ResultEntity.fail(code: .学期开学日期未设定)
        }
        
        guard loginResult == .成功 else {
            switch loginResult {
            case .用户名密码错误:
                return ResultEntity.fail(code: .用户名密码错误)
            default:
                return ResultEntity.fail(code: .未知原因登陆失败)
            }
        }
        
        guard lessons.count > 0 else {
            return ResultEntity.fail(code: .课程安排为空)
        }
        
        return ResultEntity.success(data: lessons)
    }
    
//    func getICSFile() -> ResultEntity {
//
//    }
}

// MARK: Get Course List

extension CourseService {
    private func getIDS() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        
        var ids = ""
        
        let request = URLRequest(url: URL(string: IDS_URL)!)
        urlSession.dataTask(with: request) {
            data, _, _ in
            defer { semaphore.signal() }
            
            if let data = data, let content = String(data: data, encoding: .utf8) {
                let re = try! NSRegularExpression(pattern: "bg\\.form\\.addInput\\(form,\"ids\",\"[0-9]*", options: [])
                if let match = re.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.count)) {
                    let re = try! NSRegularExpression(pattern: "[0-9]+", options: [])
                    let substring = (content as NSString).substring(with: match.range)
                    if let match = re.firstMatch(in: substring, options: [], range: NSRange(location: 0, length: substring.count)) {
                        ids = (substring as NSString).substring(with: match.range)
                    }
                }
            }
        }.resume()
        
        semaphore.wait()
        
        return ids
    }
    
    private func getCourses() -> [Course] {
        let semaphore = DispatchSemaphore(value: 0)
        
        var courseID: [String] = []
        var courseName: [String] = []
        var courseInstructor: [String] = []
        var courses: [Course] = []
        
        let postData = [
            "ignoreHead": "1",
            "setting.kind": "std",
            "startWeek": "1",
            "semester.id": semesterID,
            "ids": ids
        ]
        
        var request = URLRequest(url: URL(string: COURSE_TABLE_URL)!)
        request.encodeParameters(parameters: postData)
        urlSession.dataTask(with: request) {
            data, _, _ in
            defer { semaphore.signal() }
            
            if let data = data, let content = String(data: data, encoding: .utf8) {
                /// 获取课程代号
                var re = try! NSRegularExpression(pattern: "<td>[A-Z]{4}[0-9]{10}\\..{2}</td>", options: [])
                for match in re.matches(in: content, options: [], range: NSRange(location: 0, length: content.count)) {
                    let re = try! NSRegularExpression(pattern: "[A-Z]{4}[0-9]{10}\\..{2}", options: [])
                    let substring = (content as NSString).substring(with: match.range)
                    if let match = re.firstMatch(in: substring, options: [], range: NSRange(location: 0, length: substring.count)) {
                        courseID.append((substring as NSString).substring(with: match.range))
                    }
                }
                
                /// 获取课程名称
                re = try! NSRegularExpression(pattern: "\">.*</a></td>", options: [])
                for match in re.matches(in: content, options: [], range: NSRange(location: 0, length: content.count)) {
                    var substring = (content as NSString).substring(with: match.range)
                    substring = (substring as NSString).substring(with: NSRange(location: 2, length: substring.count - 11))
                    courseName.append(substring)
                }
                
                /// 获取任课教师
                re = try! NSRegularExpression(pattern: "\\t\\t<td>.*</td>\\n\\t", options: [])
                for match in re.matches(in: content, options: [], range: NSRange(location: 0, length: content.count)) {
                    var substring = (content as NSString).substring(with: match.range)
                    
                    var re = try! NSRegularExpression(pattern: ">.*<", options: [])
                    if let match = re.firstMatch(in: substring, options: [], range: NSRange(location: 0, length: substring.count)) {
                        substring = (substring as NSString).substring(with: match.range)
                    }
                    
                    re = try! NSRegularExpression(pattern: "<br/>", options: [])
                    substring = re.stringByReplacingMatches(in: substring, options: [], range: NSRange(location: 0, length: substring.count), withTemplate: " ")
                    
                    substring = (substring as NSString).substring(with: NSRange(location: 1, length: substring.count - 2))
                    courseInstructor.append(substring)
                }
            }
        }.resume()
        
        semaphore.wait()
        
        guard courseID.count == courseName.count, courseID.count == courseInstructor.count else {
            return courses
        }
        
        for i in 0..<courseID.count {
            courses.append(Course(courseID: courseID[i], courseName: courseName[i], courseInstructor: courseInstructor[i]))
        }
        
        return courses
    }
}

// MARK: Get Lesson List

extension CourseService {
    private func getLessons() -> [Lesson] {
        var lessons: [Lesson] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        for course in courses {
            DispatchQueue.global().async {
                defer { semaphore.signal() }
                lessons.append(contentsOf: self.getLessons(for: course))
            }
        }
        
        for _ in 0..<courses.count {
            semaphore.wait()
        }
        
        return lessons
    }
    
    private func getLessons(for course: Course) -> [Lesson] {
        let semaphore = DispatchSemaphore(value: 0)
        var lessons: [Lesson] = []
        
        let postData = [
            "lesson.semester.id": semesterID,
            "lesson.no": course.courseID
        ]
        
        var request = URLRequest(url: URL(string: COURSE_QUERY_URL)!)
        request.encodeParameters(parameters: postData)
        urlSession.dataTask(with: request) {
            data, _, _ in
            defer { semaphore.signal() }
            
            if let data = data, let content = String(data: data, encoding: .utf8) {
                /// 获取星期
                var re = try! NSRegularExpression(pattern: "<td>星期.*</td>", options: [])
                if let match = re.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.count)) {
                    let substring = (content as NSString).substring(with: match.range)
                    var lineMatch = (substring as NSString).substring(with: NSRange(location: 4, length: substring.count - 9))
                    
                    re = try! NSRegularExpression(pattern: "<br>", options: [])
                    lineMatch = re.stringByReplacingMatches(in: lineMatch, options: [], range: NSRange(location: 0, length: lineMatch.count), withTemplate: ",")
                    let splitLines = lineMatch.split(separator: ",")
                    
                    for line in splitLines {
                        let line = String(line)
                        let lineRange = NSRange(location: 0, length: line.count)
                        
                        /// 获取时间为星期*
                        let week = (line as NSString).substring(with: NSRange(location: 0, length: 3))
                        /// e.g: 星期一: 0 星期二: 1 ...
                        let dayOffset = 星期转数字[week]
                        
                        /// 获取上课节数
                        re = try! NSRegularExpression(pattern: "\\d{1,}-\\d{1,}", options: [])
                        let classOffsetMatch = re.firstMatch(in: line, options: [], range: lineRange)!
                        let classOffset = (line as NSString).substring(with: classOffsetMatch.range)
                        // e.g: 1-2 节
                        let split = classOffset.split(separator: "-")
                        /// 1 - 2 节代表着早上 8 点 - 9 点 40 的课，这个数字代表了 1.
                        let lessonStartTimeOffset = String(split[0])
                        /// 1 - 2 节代表着早上 8 点 - 9 点 40 的课，这个数字代表了 2.
                        let lessonEndTimeOffset = String(split[1])
                        
                        /// 获取上课周数
                        /// e.g: [1,2,3,4,5,6,7,8,9]
                        var weekOffset: [String] = []
                        
                        // 单周的课
                        re = try! NSRegularExpression(pattern: "\\[\\d{1,}\\]", options: [])
                        for match in re.matches(in: line, options: [], range: lineRange) {
                            var substring = (line as NSString).substring(with: match.range)
                            
                            substring = (substring as NSString).substring(with: NSRange(location: 1, length: substring.count - 2))
                            
                            weekOffset.append(substring)
                        }
                        
                        re = try! NSRegularExpression(pattern: "单?双?\\[\\d{1,}-\\d{1,}\\]", options: [])
                        for match in re.matches(in: line, options: [], range: lineRange) {
                            let substring = (line as NSString).substring(with: match.range)
                            
                            re = try! NSRegularExpression(pattern: "\\d{1,}", options: [])
                            let match = re.matches(in: substring, options: [], range: NSRange(location: 0, length: substring.count))
                            
                            let weekFirst = (substring as NSString).substring(with: match[0].range)
                            let weekLast = (substring as NSString).substring(with: match[1].range)
                            
                            if substring.contains(string: "单") || substring.contains(string: "双") {
                                for i in stride(from: Int(weekFirst)!, through: Int(weekLast)!, by: 2) {
                                    weekOffset.append(String(i))
                                }
                            } else {
                                for i in Int(weekFirst)!...Int(weekLast)! {
                                    weekOffset.append(String(i))
                                }
                            }
                        }
                        
                        /// 获取上课地点
                        re = try! NSRegularExpression(pattern: ".*\\]", options: [])
                        let location = re.stringByReplacingMatches(in: line, options: [], range: lineRange, withTemplate: "").trimmingCharacters(in: .whitespaces)
                        
                        let beginHour = 开始上课时间[lessonStartTimeOffset]
                        let endHour = 结束上课时间[lessonEndTimeOffset]
                        let beginMin = (Int(lessonStartTimeOffset)! % 2 == 0) ? 55 : 00
                        let endMin = (Int(lessonEndTimeOffset)! % 2 == 0) ? 40 : 45
                        var classTimeBeginDateComp = self.semesterBeginDateComp!
                        var classTimeEndDateComp = self.semesterBeginDateComp!
                        classTimeBeginDateComp.day! += dayOffset!
                        classTimeEndDateComp.day! += dayOffset!
                        classTimeBeginDateComp.hour = beginHour
                        classTimeEndDateComp.hour = endHour
                        classTimeBeginDateComp.minute = beginMin
                        classTimeEndDateComp.minute = endMin
                        
                        for week in weekOffset {
                            var classTimeBeginDateComp = classTimeBeginDateComp
                            var classTimeEndDateComp = classTimeEndDateComp
                            classTimeBeginDateComp.day! += (Int(week)! - 1) * 7
                            classTimeEndDateComp.day! += (Int(week)! - 1) * 7
                            
                            let classTimeBeginDate = self.calendar.date(from: classTimeBeginDateComp)
                            let classTimeEndDate = self.calendar.date(from: classTimeEndDateComp)
                            let lesson = Lesson(course: course, location: location, weekOffset: Int(week)! - 1, dayOffset: dayOffset!, startTimeOffset: Int(lessonStartTimeOffset)!, endTimeOffset: Int(lessonEndTimeOffset)!, startDateTime: classTimeBeginDate!, endDateTime: classTimeEndDate!)
                            
                            lessons.append(lesson)
                        }
                    }
                }
            }
        }.resume()
        
        semaphore.wait()
        
        return lessons
    }
}
