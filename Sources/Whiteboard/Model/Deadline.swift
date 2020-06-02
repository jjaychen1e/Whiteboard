//
//  Deadline.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/31.
//
import Foundation

class Deadline: Encodable {
//    let allDay: Bool
//    let attemptable: true
    let id: String
    let title: String
    let eventType: String
    let calendarName: String
    var url: String {
        "https://elearning.ecnu.edu.cn/webapps/calendar/launch/attempt/\(self.id)"
    }
    let calendarID: String
    let startDateTime: Date
    let endDateTime: Date

    init(id: String, title: String, eventType: String, calendarName: String, calendarID: String, startDateTime: Date, endDateTime: Date) {
        self.id = id
        self.title = title
        self.eventType = eventType
        self.calendarName = calendarName
        self.calendarID = calendarID
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
    }

    func encode(to encoder: Encoder) throws {
        enum CodingKeys: CodingKey {
            case id
            case title
            case eventType
            case calendarName
            case calendarID
            case startDateTime
            case endDateTime
        }

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(calendarName, forKey: .calendarName)
        try container.encode(calendarID, forKey: .calendarID)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        try container.encode(dateFormatter.string(from: startDateTime), forKey: .startDateTime)
        try container.encode(dateFormatter.string(from: endDateTime), forKey: .endDateTime)
    }
}
