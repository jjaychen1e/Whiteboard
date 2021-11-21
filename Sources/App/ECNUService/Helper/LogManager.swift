//
//  File.swift
//  
//
//  Created by 陈俊杰 on 2021/11/21.
//

import Foundation
import Vapor

class LogManager {
    static let logger = Logger(label: "Whiteboard")

    static func saveProcessLog(message: Logger.Message) {
        logger.info(message)
        try! CommandLineInterface.runCommand("echo", arguments: [message.description, "> \(processLogFilePath)"])
    }

    static func saveCriticalLog(message: Logger.Message) {
        logger.critical(message)
        try! CommandLineInterface.runCommand("echo", arguments: [message.description, "> \(criticalLogFilePath)"])
    }
}
