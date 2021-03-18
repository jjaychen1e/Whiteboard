//
//  ElearningService.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/30.
//
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

class ElearningService: ECNUService {
    override var LOGIN_PORTAL_URL: String {
        ELEARNING_PORTAL_URL
    }
    
    func getDeadlineList(startTimestamp: String, endTimestamp: String) -> Encodable {
        guard loginResult == .登录成功 else {
            return ResultEntity.fail(code: loginResult.toResultCode(), data: "")
        }
        let deadlines = getDeadlines(startTimestamp: startTimestamp, endTimestamp: endTimestamp)
        if deadlines.count > 0 {
            return ResultEntity.success(data: deadlines)
        } else {
            return ResultEntity.fail(code: .期限任务列表为空, data: "")
        }
    }
    
    /// Generate corresponding deadline calendarID if success, otherwise return nil
    func generateDeadlineCalendarID() -> (isSuccess: Bool, code: ResultCode, calendarID: String?) {
        guard loginResult == .登录成功, isUserInfoSaveSuccess == true else {
            return (false, loginResult == .登录成功 ? .数据库保存失败 : loginResult.toResultCode(), nil)
        }
        
        return (true, .成功, username.encodeToCalendarID())
    }
    
    func getDeadlineCalendar() -> ResultEntity<Dictionary<String, String>> {
        guard loginResult == .登录成功 else {
            return ResultEntity.fail(code: loginResult.toResultCode(), data: [:])
        }
        
        let calendar = Calendar.current
        let beginDateComponents = calendar.dateComponents([.year], from: Date())
        var endDateComponents = beginDateComponents
        endDateComponents.year! += 2
        let beginTimestamp = String(Int(calendar.date(from: beginDateComponents)!.timeIntervalSince1970)) + "000"
        let endTimestamp = String(Int(calendar.date(from: endDateComponents)!.timeIntervalSince1970)) + "000"
        let deadlines = getDeadlines(startTimestamp: beginTimestamp, endTimestamp: endTimestamp)
        
        let calendarName = "大夏学堂 Deadline 订阅"
        let icsCalendar = getDeadlineICSCalendar(deadlines: deadlines)
        
        return ResultEntity.success(data: [
            "fileName": calendarName + ".ics",
            "content": icsCalendar.toICSDescription()
        ])
    }
}

// MARK: Get Deadline List

extension ElearningService {
    private func getDeadlines(startTimestamp: String, endTimestamp: String) -> [Deadline] {
        var deadlines: [Deadline] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        
        if let queryURLString = "\(ECNU_ELEARNING_DEADLINE_URL)?start=\(startTimestamp)&end=\(endTimestamp)".addingPercentEncoding(withAllowedCharacters:
        .urlQueryAllowed), let url = URL(string: queryURLString) {
            let request = URLRequest(url: url)
            
            urlSession.dataTask(with: request) {
                data, _, _ in
                defer { semaphore.signal() }
                
                if let data = data {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
                    for deadline in result ?? [] {
                        let deadlineItem = Deadline(id: deadline["id"] as! String,
                                                    title: deadline["title"] as! String,
                                                    eventType: deadline["eventType"] as! String,
                                                    calendarName: deadline["calendarName"] as! String,
                                                    calendarID: deadline["calendarId"] as! String,
                                                    startDateTime: dateFormatter.date(from: deadline["start"] as! String)!,
                                                    endDateTime: dateFormatter.date(from: deadline["end"] as! String)!)
                        
                        deadlines.append(deadlineItem)
                    }
                }
            }.resume()
            
            semaphore.wait()
        }
        
        return deadlines
    }
}

// MARK: Get Calander Feed

extension ElearningService {
    func getDeadlineICSCalendar(deadlines: [Deadline]) -> ICSCalendar {
        let calendar = ICSCalendar(name: "大夏学堂 Deadline 订阅")
        for deadline in deadlines {
            var startTime = deadline.startDateTime
            let endTime = deadline.endDateTime
            if(startTime == endTime) {
                startTime = startTime.addingTimeInterval(-3600)
            }
            let event = ICSEvent(startDate: startTime,
                     endDate: endTime,
                     title: "\(deadline.calendarName) - " + deadline.title,
                     note: deadline.url)
            event.setAlarm(alarm: .init(trigger: .day(-1), action: .audio))
            calendar.append(event: event)
        }
        return calendar
    }
}
