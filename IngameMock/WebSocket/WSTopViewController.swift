//
//  WSTopViewController.swift
//  IngameMock
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
    
    private lazy var manager: SocketManager = SocketManager(socketURL: URL(string: "http://192.168.2.1:3000")!, config: [.log(true), .compress])
    private var socket: SocketIOClient {
        return manager.defaultSocket
    }
    
    @IBAction private func btnHello(sender: UIButton) {
        socket.emit("from_client", "Hello")
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblAddress?.text = NetworkManager.getIPAddress()
    }
    
    
    private func start() {
        
        socket.on("connect") { [weak self] data, ack in
            print("socket connected")
            self?.socket.emit("from_client", "Hello")
        }
        
        socket.on("from_server") { [weak self] data, ack in
            if let msg = data[0] as? String {
                let text = self?.tvLog?.text ?? ""
                self?.tvLog?.text = msg + "\n" + text
            }
        }
        
        socket.connect()
    }
}
