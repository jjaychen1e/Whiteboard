//
//  LogManager.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/6/1.
//

import PerfectLogger
import Foundation

class LogManager {
    static func saveProcessLog(message: String, eventID: String) {
        LogFile.info(message, eventid: eventID, logFile: processLogFilePath)
    }
    
//    static func saveResultLog(username: String, year: String, semesterIndex: String, description: String, eventID: String) {
//        var yearSemesterDescription = ""
//        if let yearInt = Int(year) {
//            yearSemesterDescription = "\(yearInt)-\(yearInt + 1) 学年第 \(semesterIndex) 学期"
//        } else {
//            yearSemesterDescription = "\(year) 学年第 \(semesterIndex) 学期"
//        }
//        
//        
//        LogFile.info("\(username) 请求生成 \(yearSemesterDescription) 课程表结果为：\(description)", eventid: eventID, logFile: processLogFilePath)
//        LogFile.info("\(username) 请求生成 \(yearSemesterDescription) 课程表结果为：\(description)", eventid: eventID, logFile: resultLogFilePath)
//        
//        if !saveRecord(username: username, year: year, semesterIndex: semesterIndex, description: description) {
//            LogFile.info("数据库记录结果失败", eventid: eventID, logFile: processLogFilePath)
//            LogFile.info("数据库记录结果失败", eventid: eventID, logFile: resultLogFilePath)
//        }
//    }
//    
//    private static func saveRecord(username: String, year: String, semesterIndex: String, description: String) -> Bool{
//        let sql = """
//        INSERT INTO ecnu_ics_record(username, year, semester_index, description)
//        values(\"\(username)\", \"\(year)\", \"\(semesterIndex)\", \"\(description)\")
//        """
//        
//        return MySQLConnector.query(statement: sql).isSuccess
//    }
}
