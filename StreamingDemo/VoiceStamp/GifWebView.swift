//
//  GifWebView.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/19.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import WebKit

class GifWebView: WKWebView {

    private var data: Data?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }

    override private init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.initialize()
    }

    convenience init?(fileName: String, origin: CGPoint = CGPoint.zero) {
        guard let gifData = NSDataAsset(name: fileName)?.data else { return nil }
        guard let image = UIImage(data: gifData as Data) else { return nil }
        self.init(frame: CGRect(origin: origin, size: image.size))
        self.data = gifData as Data
    }

    private func initialize() {
        self.scrollView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false
    }

    func startAnimate() {
        guard let data = self.data else { return }
        guard let url = NSURL(string: "") else { return }
        self.load(data, mimeType: "image/gif", characterEncodingName: "utf-8", baseURL: url as URL)
    }
}
