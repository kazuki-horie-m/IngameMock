//
//  WSTopViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/06.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import SocketIO

class WSTopViewController: UIViewController {
    @IBOutlet private weak var lblAddress: UILabel?
    @IBOutlet private weak var tfAddress: UITextField?
    @IBOutlet private weak var tvLog: UITextView?

    //    private let destinationUrlString: String = "http://192.168.2.1:8188"
    //    private let destinationUrlString: String = "ws://192.168.2.1:8188"
    private let destinationUrlString: String = "ws://10.196.221.231:8188" // open-smapho24
    //    private let destinationUrlString: String = "ws://10.196.42.175:8188" // mx-data
    private lazy var destinationUrl: URL = {
        guard let url = URL(string: destinationUrlString) else { fatalError("destinationURL") }
        return url
    }()
    private lazy var manager = SocketManager(socketURL: destinationUrl, config: [.log(true), .compress])
    private var socket: SocketIOClient {
        return manager.defaultSocket
    }

    @IBAction private func btnHello(sender: UIButton) {
        socket.emit("from_client", "Hello")
        //        let data: [String: String] = [
        //            "display": "t",
        //            "ptype": "publisher",
        //            "request": "join",
        //            "room": "1234"
        //        ]
        //        socket.emit("janus", data)
    }

    @IBAction private func btnBang(sender: UIButton) {
        socket.emit("from_client", "Bang")
    }

    @IBAction private func btnBye(sender: UIButton) {
        socket.emit("from_client", "Bye")
    }

    @IBAction private func btnConnect(sender: UIButton) {
        start()
    }

    @IBAction private func btnDisconnect(sender: UIButton) {
        socket.disconnect()
        socket.removeAllHandlers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfAddress?.text = destinationUrlString
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lblAddress?.text = NetworkManager.getIPAddress()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        socket.removeAllHandlers()
    }

    private func start() {
        socket.removeAllHandlers()

        socket.on("connect") { [weak self] _, _ in
            print("socket connected")
            self?.socket.emit("from_client", "Hello")
        }

        socket.on("from_server") { [weak self] data, _ in
            print("socket from_server")
            if let msg = data[0] as? String {
                let text = self?.tvLog?.text ?? ""
                self?.tvLog?.text = msg + "\n" + text
            }
        }

        socket.connect()
    }
}
