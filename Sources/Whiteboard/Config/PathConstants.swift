//
//  PathConstants.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

import Foundation

let JS_FILE_PATH = TEMP_PREXFIX + "/getRSA.js"
var NODE_PATH = "/usr/bin/node"
var CONVERT_PATH = "/usr/bin/convert"
var TESSERACT_PATH = "/usr/bin/tesseract"
let TEMP_PREXFIX = "\(FileManager.default.currentDirectoryPath)/tmp"

#if os(Linux)
let processLogFilePath = "/var/log/ecnu-service-process.log"
let criticalLogFilePath = "/var/log/ecnu-service-critical.log"
let resultLogFilePath = "/var/log/ecnu-service-result.log"
#else
let processLogFilePath = TEMP_PREXFIX + "/ecnu-service-process.log"
let criticalLogFilePath = TEMP_PREXFIX + "/ecnu-service-critical.log"
let resultLogFilePath = TEMP_PREXFIX + "/ecnu-service-result.log"
#endif

/// Random file name with time and random Int value.
/// Example: 2020-03-03-01-17-42-5-captacha.png
var CAPTCHA_PATH: String {
    let prefix = TEMP_PREXFIX

    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "YYYY-MM-dd-HH-mm-ss-SSS"
    let randomSuffic = String(Int.random(in: 0...1000))
    let suffix = dateformatter.string(from: Date()) + "-" + randomSuffic + "-captcha.jpg"

    return prefix + "/" + suffix
}

func initializePath() {
    if FileManager.default.fileExists(atPath: "/usr/bin/tesseract") {
        TESSERACT_PATH = "/usr/bin/tesseract"
    } else if FileManager.default.fileExists(atPath: "/usr/local/bin/tesseract") {
        TESSERACT_PATH = "/usr/local/bin/tesseract"
    } else {
        fatalError("tesseract cannot be found in both '/usr/bin/tesseract' or '/usr/local/bin/tesseract'")
    }

    // Generate tesseract config file.
    #if os(Linux)
    let tessconfigsDirectoryPath = String(runCommand(launchPath: "/usr/bin/find", arguments: ["/usr/share/", "-name", "tessconfigs"]).split(separator: "\n").first!)
    #else
    let tesseractRealPath = runCommand(launchPath: "/usr/bin/readlink", arguments: [TESSERACT_PATH])
    let tessconfigsDirectoryPath = TESSERACT_PATH.truncation() + "/" + tesseractRealPath.truncation(2) + "/share/tessdata/tessconfigs"
    #endif

    let captchaConfigFilePath = tessconfigsDirectoryPath + "/captcha"
    
    if FileManager.default.fileExists(atPath: tessconfigsDirectoryPath) {
        try! "tessedit_char_whitelist 0123456789\n".data(using: .utf8)?.write(to: URL(fileURLWithPath: captchaConfigFilePath))
    } else {
        fatalError("Cannot find tessconfigs directory: \(tessconfigsDirectoryPath)")
    }
    
    if FileManager.default.fileExists(atPath: "/usr/bin/node") {
        NODE_PATH = "/usr/bin/node"
    } else if FileManager.default.fileExists(atPath: "/usr/local/bin/node") {
        NODE_PATH = "/usr/local/bin/node"
    } else {
        fatalError("NodeJS cannot be found in both '/usr/bin/node' or '/usr/local/bin/node'")
    }

    if FileManager.default.fileExists(atPath: "/usr/bin/convert") {
        CONVERT_PATH = "/usr/bin/convert"
    } else if FileManager.default.fileExists(atPath: "/usr/local/bin/convert") {
        CONVERT_PATH = "/usr/local/bin/convert"
    } else {
        fatalError("ImageMagick cannot be found in both '/usr/bin/convert' or '/usr/local/bin/convert'")
    }
}

extension String {
    // 截断至最后一个 '/'
    fileprivate func truncation() -> String {
        if let index = lastIndex(of: "/") {
            return String(self[..<index])
        }
        return ""
    }

    // 截断至最后第 i 个 '/'
    fileprivate func truncation(_ time: Int) -> String {
        var result = self
        for _ in 1...time {
            result = result.truncation()
        }
        return result
    }
}
