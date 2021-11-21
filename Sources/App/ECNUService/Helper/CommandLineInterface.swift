//
//  CommandLineInterface.swift
//  
//
//  Created by 陈俊杰 on 2021/11/21.
//

import Foundation
import ShellOut

class CommandLineInterface {
    @discardableResult
    static func runCommand(_ command: String, arguments: [String]) throws -> String {
        try shellOut(to: command, arguments: arguments)
    }
}
