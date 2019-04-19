//
//  ContainerViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/29.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    @IBOutlet private weak var label: UILabel?

    @IBAction func dismissView(sender: UIButton) {
        super.dismiss(animated: true, completion: nil)
    }

    var identifier: String? {
        didSet {
            label?.text = identifier
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        label?.text = identifier
    }

}
