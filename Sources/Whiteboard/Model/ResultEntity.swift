//
//  ResultEntity.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

import Foundation

struct ResultEntity<T: Encodable>: Encodable {
    var code: ResultCode
    var message: String
    var data: T
    
    static func success(data: T) -> Self {
        Self(code: .成功, message: "success", data: data)
    }

    static func success(message: String, data: T) -> Self {
        Self(code: .成功, message: message, data: data)
    }

    static func fail(code: ResultCode, data: T) -> Self {
        Self(code: code, message: code.toString(), data: data)
    }
}
