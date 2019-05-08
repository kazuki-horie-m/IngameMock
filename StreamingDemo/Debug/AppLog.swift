//
//  AppLog.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/04/01.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation

extension Notification.Name {
    struct Debug {
        static let AppLogNotification = Notification.Name("debug.appLogNotification")
    }
}

struct AppLogData {
    var level: String
    var message: String
}

final class AppLog {
    class func debug(_ item: Any) {
        let message = "[TCTC] " + String(describing: item)
        print(message)
//        sendNotification(AppLogData(level: "debug", message: message))
    }
    
    class func info(_ item: Any) {
        let message = "[TCTC] " + String(describing: item)
        print(message)
        notify(AppLogData(level: "info", message: message))
    }
    
    class func warning(_ item: Any) {
        let message = "[TCTC] " + String(describing: item)
        print(message)
        notify(AppLogData(level: "warning", message: message))
    }
    
    class func error(_ item: Any) {
        let message = "[TCTC] " + String(describing: item)
        print(message)
        notify(AppLogData(level: "error", message: message))
    }
    
    class func notify(_ logData: AppLogData) {
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name.Debug.AppLogNotification, object: logData, userInfo: nil)
        center.post(notification)
    }
}
