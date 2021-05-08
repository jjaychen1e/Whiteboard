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
            LogManager.saveProcessLog(message: "数据库连接失败: \(mysql.errorMessage())")
            return (false, nil)
        }
        
        if mysql.query(statement: sql) {
            return (true, mysql.storeResults() ?? nil)
        } else {
            LogManager.saveProcessLog(message: "数据库 Query 失败: \(mysql.errorMessage())")
            return (false, nil)
        }
    }
    
    @discardableResult
    static func updateUser(schoolID: String, rsa: String, passwordLength: Int) -> Bool {
        let sql = """
        REPLACE INTO user(school_id, rsa, password_length) VALUES("\(schoolID)", "\(rsa)", \(passwordLength));
        """
        
        return MySQLConnector.query(statement: sql).isSuccess
    }
    
    @discardableResult
    static func updateUuidUser(uuid: String, schoolID: String, rsa: String, passwordLength: Int) -> Bool {
        let sql = """
        REPLACE INTO uuid_user(uuid, school_id, rsa, password_length) VALUES("\(uuid)", \(schoolID)", "\(rsa)", \(passwordLength));
        """
        
        return MySQLConnector.query(statement: sql).isSuccess
    }
    
    static func queryUserInfo(uuid: String) -> (isSuccess: Bool, username: String, rsa: String, passwordLength: Int) {
        var result = (isSuccess: false, username: "", rsa: "", passwordLength: 0)
        
        let uuidSQL = """
        select * FROM uuid_user WHERE uuid = \(uuid);
        """
        if let uuidResults = MySQLConnector.query(statement: uuidSQL).results {
            uuidResults.forEachRow { row in
                result.isSuccess = true
                result.username = row[1]!
                result.rsa = row[2]!
                result.passwordLength = Int(row[3]!)!
            }
        }
        
        return result
    }
}
