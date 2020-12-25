//
//  LogManager.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/6/1.
//

import PerfectLogger
import Foundation

class LogManager {
    static func saveProcessLog(message: String) {
        LogFile.info(message, logFile: processLogFilePath)
    }
    
    static func saveCriticalLog(message: String) {
        LogFile.critical(message, logFile: criticalLogFilePath)
    }
}
