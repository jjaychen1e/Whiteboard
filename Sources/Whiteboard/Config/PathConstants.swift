//
//  PathConstants.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

import Foundation

let PYTHON3_PATH = "/usr/local/bin/python3"
let TESSERACT_PATH = "tesseract"
//let TESSERACT_PATH = "/usr/local/bin/tesseract"
let TEMP_PREXFIX = "\(FileManager.default.currentDirectoryPath)/tmp"
//let RECOGNIZE_PATH = TEMP_PREXFIX + "/recognize.py"

#if os(Linux)
let GETRSA_PATH = TEMP_PREXFIX + "/getRSA.py"
#endif

/// Random file name with time and random Int value.
/// Example: 2020-03-03-01-17-42-5-captacha.png
var CAPTCHA_PATH: String {
    let prefix = TEMP_PREXFIX
    
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "YYYY-MM-dd-HH-mm-ss"
    let randomSuffic = String(Int.random(in: 0...10))
    let suffix = dateformatter.string(from: Date()) + "-" + randomSuffic + "-captcha.png"
    
    return  prefix + "/" + suffix
}

