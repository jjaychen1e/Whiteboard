//
//  ResultEntity.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

import Foundation

class ResultEntity: Encodable {
    private typealias ResultDataEncoder = (Any, inout KeyedEncodingContainer<CodingKeys>) throws -> Void
    
    let code: ResultCode
    let message: String
    let data: Encodable?
    private let dataEncoder: ResultDataEncoder?
    
    enum CodingKeys: CodingKey {
        case code
        case message
        case data
    }
    
    init<T: Encodable>(code: ResultCode, message: String, data: T?) {
        self.code = code
        self.message = message
        self.data = data
        self.dataEncoder = { data, container in
            try container.encode(data as! T, forKey: .data)
        }
    }
    
    static func success<T: Encodable>(data: T?) -> ResultEntity {
        ResultEntity(code: .成功, message: "success", data: data)
    }
    
    static func success<T: Encodable>(message: String, data: T?) -> ResultEntity {
        ResultEntity(code: .成功, message: message, data: data)
    }
    
    static func fail<T: Encodable>(code: ResultCode, data: T) -> ResultEntity {
        ResultEntity(code: code, message: code.toString(), data: data)
    }
    
    static func fail(code: ResultCode) -> ResultEntity {
        ResultEntity(code: code, message: code.toString(), data: "")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
        try dataEncoder?(data as Any, &container)
    }
}
