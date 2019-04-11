//
//  Encodable+.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/04/11.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
