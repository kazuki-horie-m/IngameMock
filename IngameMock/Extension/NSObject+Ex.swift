//
//  NSObject+Ex.swift
//  IngameMock
//
//  Created by kazuki.horie.ts on 2019/03/06.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import Foundation

extension NSObject {
    static var className: String {
        let classnameWithModule = NSStringFromClass(self)
        let classname = String(classnameWithModule.split(separator: ".").last!)
        return classname
    }
}
