//
//  TopNavigationContrller.swift
//  IngameMock
//
//  Created by kazuki.horie.ts on 2019/03/06.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit

class TopNavigationContrller: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationBar.isTranslucent = true
//        navigationBar.backgroundImage(for: <#T##UIBarMetrics#>)
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

    }
}
