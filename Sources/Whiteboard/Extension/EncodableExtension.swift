//
//  EncodableExtension.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

import Foundation

public extension Encodable {
    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func toJSONString() -> String? {
        if let bytes = toJSONData() {
            return String(bytes: bytes, encoding: .utf8)
        }
        return nil
    }
    
    func toJSON() -> [String: String] {
        guard let data = toJSONData() else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: String] } ?? [:]
    }
}
