//
//  MySQLConnector.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/6/1.
//

import Foundation
import PerfectMySQL

let databaseHost = "127.0.0.1"
let databaseUser = "root"
let databasePassword = "Chen27049999"
let databaseSchema = "ecnu_service_schema"
//
class MySQLConnector {
    static func query(statement sql: String) -> (isSuccess: Bool, results: MySQL.Results?) {
        let mysql = MySQL()
        mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8")
        
        defer { mysql.close() }
        
        guard mysql.connect(host: databaseHost, user: databaseUser, password: databasePassword, db: databaseSchema) else {
//            LogManager.saveProcessLog(message: "数据库连接失败: \(mysql.errorMessage())", eventID: "-1")
            return (false, nil)
        }
        
        if mysql.query(statement: sql) {
            return (true, mysql.storeResults() ?? nil)
        } else {
//            LogManager.saveProcessLog(message: "数据库 Query 失败: \(mysql.errorMessage())", eventID: "-1")
            return (false, nil)
        }
    }
    
    static func updateUser(schoolID: String, rsa: String, passwordLength: Int) -> Bool {
        let sql = """
        REPLACE INTO user(school_id, rsa, password_length) VALUES("\(schoolID)", "\(rsa)", \(passwordLength));
        """
        
        return MySQLConnector.query(statement: sql).isSuccess
    }
    
    static func queryUserInfo(calendarID: String) -> (isSuccess: Bool, username: String, rsa: String, passwordLength: Int) {
        let sql = """
        select * FROM user WHERE school_id = \(calendarID.decodeToID());
        """
        var result = (isSuccess: false, username: "", rsa: "", passwordLength: 0)
        if let results = MySQLConnector.query(statement: sql).results {
            results.forEachRow { row in
                result.isSuccess = true
                result.username = row[0]!
                result.rsa = row[1]!
                result.passwordLength = Int(row[2]!)!               
                return
            }
        }
        
        return result
    }
    
//    static func getNextSessionID() -> String {
//        let sql = """
//        select auto_increment from information_schema.`TABLES`
//        where table_name='\(databaseTable)'
//        """
//
//        var nextID: String?
//
//        if let results = MySQLConnector.query(statement: sql).results {
//            results.forEachRow { row in
//                nextID = row[0]!
//                return
//            }
//        }
//
//        if let nextID = nextID {
//            return nextID
//        }
//
//        return "-1"
//    }
}
