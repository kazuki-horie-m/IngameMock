//
//  StreamingTopViewController.swift
//  IngameMock
//
//  Created by kazuki.horie.ts on 2019/02/27.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import AVFoundation
import HaishinKit
import VideoToolbox

class StreamingTopViewController: UIViewController {
    @IBOutlet private weak var ipaddressLabel: UILabel?
    @IBOutlet private weak var cameraView: UIView?
    @IBOutlet private weak var parentView: UIView?
    @IBOutlet private weak var childView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction private func switchPlayer(sender: UIButton) {
        let parent = StreamingPlayerManager.shared.vcParent?.player
        let child = StreamingPlayerManager.shared.vcChild?.player
        
        StreamingPlayerManager.shared.vcParent?.player = child
        StreamingPlayerManager.shared.vcChild?.player = parent
    }
    
    @IBAction private func switchView(sender: UIButton) {
        
    }
    
    @IBAction private func startLive(sender: UIButton) {
        StreamingPlayerManager.shared.vcLive?.startLive()
    }
    
    @IBAction private func stopLive(sender: UIButton) {
        StreamingPlayerManager.shared.vcLive?.stopLive()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ipaddressLabel?.text = StreamingTopViewController.getIPAddress()
    }
    
    class func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    if let name: String = String(cString: (interface?.ifa_name)!), name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}


