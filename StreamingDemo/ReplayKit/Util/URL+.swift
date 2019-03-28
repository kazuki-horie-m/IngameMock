//
//  URL+.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/28.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation

extension URL {
    var absoluteWithoutAuthenticationString: String {
        guard var components = URLComponents(string: absoluteString) else { return absoluteString }
        components.password = nil
        components.user = nil
        return components.url?.absoluteString ?? absoluteString
    }
    
    var absoluteWithoutQueryString: String {
        guard let query: String = self.query else {
            return self.absoluteString
        }
        return absoluteString.replacingOccurrences(of: "?" + query, with: "")
    }
    
    func dictionaryFromQuery() -> [String: String] {
        var result: [String: String] = [:]
        guard let query = URLComponents(string: absoluteString)?.queryItems else {
            return result
        }
        for item in query {
            if let value: String = item.value {
                result[item.name] = value
            }
        }
        return result
    }
}
