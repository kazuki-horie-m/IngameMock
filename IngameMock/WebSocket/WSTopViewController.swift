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
    
    @IBAction private func btnHello(sender: UIButton) {
        
    }
    
    @IBAction private func btnBang(sender: UIButton) {
        
    }
    
    @IBAction private func btnBye(sender: UIButton) {
        
    }
    
    @IBAction private func btnConnect(sender: UIButton) {
        start()
    }
    
    @IBAction private func btnDisconnect(sender: UIButton) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblAddress?.text = NetworkManager.getIPAddress()
    }
    
    
    private func start() {
        let manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .compress])
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on("currentAmount") {data, ack in
            guard let cur = data[0] as? Double else { return }
            
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                socket.emit("update", ["amount": cur + 2.50])
            }
            
            ack.with("Got your currentAmount", "dude")
        }
        
        socket.connect()
    }
}
