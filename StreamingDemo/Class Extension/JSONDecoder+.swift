//
//  JSONDecoder+.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/04/11.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation

extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, withJSONObject object: Any, options opt: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: opt)
        return try decode(T.self, from: data)
    }

    func decode<T: Decodable>(_ type: T.Type, from data: [String: Any]) -> T? {
        dateDecodingStrategy = .iso8601
        return try? decode(T.self, withJSONObject: data)
    }
}
