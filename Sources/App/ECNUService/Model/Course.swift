//
//  Course.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

struct Course: Encodable {
    let courseID: String
    let courseName: String
    let courseInstructor: String
    
    init(courseID: String, courseName: String, courseInstructor: String) {
        self.courseID = courseID
        self.courseName = courseName
        self.courseInstructor = courseInstructor
    }
}
