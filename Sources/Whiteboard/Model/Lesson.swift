//
//  Lesson.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/29.
//
import Foundation

class Lesson: Encodable {
    let courseID: String
    let courseName: String
    let location: String
    let weekOffset: Int
    let dayOffset: Int
    let startTimeOffset: Int
    let endTimeOffset: Int
    let startDateTime: Date
    let endDateTime: Date
    
    init(courseID: String, courseName: String, location: String, weekOffset: Int, dayOffset: Int, startTimeOffset: Int, endTimeOffset: Int, startDateTime: Date, endDateTime: Date) {
        self.courseID = courseID
        self.courseName = courseName
        self.location = location
        self.weekOffset = weekOffset
        self.dayOffset = dayOffset
        self.startTimeOffset = startTimeOffset
        self.endTimeOffset = endTimeOffset
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
    }
    
    init(course: Course, location: String, weekOffset: Int, dayOffset: Int, startTimeOffset: Int, endTimeOffset: Int, startDateTime: Date, endDateTime: Date) {
        self.courseID = course.courseID
        self.courseName = course.courseName
        self.location = location
        self.weekOffset = weekOffset
        self.dayOffset = dayOffset
        self.startTimeOffset = startTimeOffset
        self.endTimeOffset = endTimeOffset
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
    }
    
    func encode(to encoder: Encoder) throws {
        enum CodingKeys: CodingKey {
            case courseID
            case courseName
            case location
            case weekOffset
            case dayOffset
            case startTimeOffset
            case endTimeOffset
            case startDateTime
            case endDateTime
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(courseID, forKey: .courseID)
        try container.encode(courseName, forKey: .courseName)
        try container.encode(location, forKey: .location)
        try container.encode(weekOffset, forKey: .weekOffset)
        try container.encode(dayOffset, forKey: .dayOffset)
        try container.encode(startTimeOffset, forKey: .startTimeOffset)
        try container.encode(endTimeOffset, forKey: .endTimeOffset)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        try container.encode(dateFormatter.string(from: startDateTime), forKey: .startDateTime)
        try container.encode(dateFormatter.string(from: endDateTime), forKey: .endDateTime)
    }
}
