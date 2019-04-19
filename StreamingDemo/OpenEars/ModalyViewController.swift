//
//  ModalyViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/28.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit

class ModalyViewController: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ContainerViewController
            else { return }

        vc.identifier = segue.identifier
    }
}
