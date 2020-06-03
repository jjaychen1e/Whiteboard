//
//  PathConstants.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

import Foundation

func initializePath() {
    if FileManager.default.fileExists(atPath: "/usr/bin/tesseract") {
        TESSERACT_PATH = "/usr/bin/tesseract"
    } else if FileManager.default.fileExists(atPath: "/usr/local/bin/tesseract") {
        TESSERACT_PATH = "/usr/local/bin/tesseract"
    } else {
        fatalError("tesseract cannot be found in both '/usr/bin/tesseract' or '/usr/local/bin/tesseract'")
    }

    if FileManager.default.fileExists(atPath: "/usr/bin/node") {
        TESSERACT_PATH = "/usr/bin/node"
    } else if FileManager.default.fileExists(atPath: "/usr/local/bin/node") {
        TESSERACT_PATH = "/usr/local/bin/node"
    } else {
        fatalError("NodeJS cannot be found in both '/usr/bin/node' or '/usr/local/bin/node'")
    }
}

let JS_FILE_PATH = TEMP_PREXFIX + "/getRSA.js"
var NODE_PATH = "/usr/bin/node"
var TESSERACT_PATH = "/usr/bin/tesseract"
let TEMP_PREXFIX = "\(FileManager.default.currentDirectoryPath)/tmp"

#if os(Linux)
let processLogFilePath = "/var/log/ecnu-service-process.log"
let resultLogFilePath = "/var/log/ecnu-service-result.log"
#else
let processLogFilePath = TEMP_PREXFIX + "/ecnu-service-process.log"
let resultLogFilePath = TEMP_PREXFIX + "/ecnu-service-result.log"
#endif

/// Random file name with time and random Int value.
/// Example: 2020-03-03-01-17-42-5-captacha.png
var CAPTCHA_PATH: String {
    let prefix = TEMP_PREXFIX

    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "YYYY-MM-dd-HH-mm-ss"
    let randomSuffic = String(Int.random(in: 0...10))
    let suffix = dateformatter.string(from: Date()) + "-" + randomSuffic + "-captcha.png"

    return prefix + "/" + suffix
}
