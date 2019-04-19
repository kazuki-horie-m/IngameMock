//
//  AppLog.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/04/01.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation

class AppLog {
    class func debug(_ item: Any) {
        print("[TCTC] " + String(describing: item))
    }
}
