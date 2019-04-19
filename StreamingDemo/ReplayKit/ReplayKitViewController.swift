//
//  ReplayKitViewController.swift
//  StreamingDemo
//
//  Created by Kazuki Horie on 2019/03/21.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit
import ReplayKit

class ReplayKitViewController: UIViewController {
    @IBOutlet private weak var broadcastPicker: RPSystemBroadcastPickerView?

    @IBAction private func connectAction(sender: UIButton) {
        connect()
    }

    @IBAction private func startAction(sender: UIButton) {
        start()
    }

    @IBAction private func pauseAction(sender: UIButton) {
        pause()
    }

    @IBAction private func resumeAction(sender: UIButton) {
        resume()
    }

    @IBAction private func stopAction(sender: UIButton) {
        finish()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //        broadcastPicker?.preferredExtension = "com.tctc.rinrin.StreamingDemoUpload1"
    }

    private func connect() {
        //        RPBroadcastActivityViewController.load(handler: { [unowned self] vc, error in
        RPBroadcastActivityViewController.load(withPreferredExtension: "com.tctc.rinrin.StreamingDemoUpload2") { [unowned self] vc, _ in
            if let vc = vc {
                vc.delegate = self
                vc.modalPresentationStyle = .popover
                self.present(vc, animated: true, completion: nil)
                //                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }

        //        RPBroadcastActivityViewController.load(handler: { [unowned self] vc, error in
        //            if let vc = vc {
        //                vc.delegate = self
        //                self.present(vc, animated: false, completion: nil)
        //            }
        //        })
    }

    private func start() {
        broadCastController?.startBroadcast(handler: { err in
            print(err?.localizedDescription as Any)
        })
    }

    private func pause() {
        broadCastController?.pauseBroadcast()
    }

    private func resume() {
        broadCastController?.resumeBroadcast()
    }

    private func finish() {
        broadCastController?.finishBroadcast(handler: { _ in
            print("finished")
        })
    }

    private var broadCastController: RPBroadcastController?
}

extension ReplayKitViewController: RPBroadcastActivityViewControllerDelegate {
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        self.broadCastController = broadcastController
        //        broadcastController?.startBroadcast(handler: { err in
        //            print(err?.localizedDescription)
        //        })
        DispatchQueue.main.async {
            broadcastActivityViewController.dismiss(animated: false, completion: nil)
            //        dismiss(animated: false, completion: nil)
        }
    }
}
