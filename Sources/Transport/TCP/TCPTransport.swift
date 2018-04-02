//
//  TCPTransport.swift
//  StatsdClient
//
//  Created by Khoi Lai on 10/11/17.
//  Copyright © 2017 StatsdClient. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public class TCPTransport: NSObject, Transport {
    let host: String
    let port: UInt16

    private var completionBlocks = [Int: TransportCompletionCallback]()
    private var tag: Int = 0
    private var timeOut: TimeInterval

    private lazy var socket: GCDAsyncSocket = {
        GCDAsyncSocket(delegate: self,
                       delegateQueue: DispatchQueue(label: "TCPClient_Delegate_Queue"))
    }()

    public init(host: String, port: UInt16, timeOut: TimeInterval = 15) {
        self.host = host
        self.port = port
        self.timeOut = timeOut
        super.init()
    }

    public func write(data: String, completion: TransportCompletionCallback?) {
        guard let data = data.data(using: String.Encoding.utf8) else {
            completion?(TransportError.invalidData)
            return
        }

        if tag == Int.max {
            tag = 0
        }
        tag += 1

        socket.write(data, withTimeout: timeOut, tag: tag)
    }
}

extension TCPTransport: GCDAsyncSocketDelegate {
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        guard let callback = completionBlocks[tag] else {
            return
        }
        callback(nil)
        completionBlocks[tag] = nil
    }

    public func socket(_ sock: GCDAsyncSocket,
                       shouldTimeoutWriteWithTag tag: Int,
                       elapsed: TimeInterval,
                       bytesDone length: UInt) -> TimeInterval {
        completionBlocks[tag]?(TransportError.timeout)
        completionBlocks[tag] = nil
        return -1
    }
}
