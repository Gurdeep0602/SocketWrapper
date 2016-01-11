//
//  GSNetworking.swift
//  SocketWrapper
//
//  Created by Gurdeep Singh on 05/01/16.
//  Copyright © 2016 Gurdeep Singh. All rights reserved.
//

import Foundation

let GSNetworking = __GSNetworking__.instance

typealias JSONDictionary = [String : AnyObject]
typealias JSONDictionaryArray = [[String : AnyObject]]

let BASE_URL = "http://46.4.99.7:8004"

class __GSNetworking__ {

    
    typealias webServiceSuccess = (json : JSON) -> Void
    typealias webServiceFailure = (error : NSError) -> Void

    static let instance = __GSNetworking__()
    
    private let socket = SocketIOClient(socketURL: "http://46.4.99.7:8004", options: [ "reconnectAttempts": 5 ])
    
    private var isConnected = false {
    
        didSet{
        
            if let block = awaitingBlock where isConnected {
                block()
            }
        }
    }
    
    private var isConnectingSocket = false
    
    private var awaitingBlock : (()->())?
    
    private init() {
    
        connectSocket()
        
        socket.on("connect") { (data:[AnyObject], ack:SocketAckEmitter) -> Void in
            print("                  Socket Connected")
            self.isConnected = true
            self.isConnectingSocket = false
        }

        socket.on("disconnect") { (data:[AnyObject], ack:SocketAckEmitter) -> Void in
            print("                  Socket Disconnected")
            self.isConnected = false
            self.isConnectingSocket = false
        }

        socket.on("error") { (data:[AnyObject], ack:SocketAckEmitter) -> Void in
            print("Error Occurred")
            print(data)
        }

//        socket.on("reconnect") { (data:[AnyObject], ack:SocketAckEmitter) -> Void in
//            print("Socket Re-connected")
//        }

        socket.on("reconnectAttempt") { (data:[AnyObject], ack:SocketAckEmitter) -> Void in
            print("Attempting Re-connect...")
            self.isConnectingSocket = true
        }
        
    }
    
    private func connectSocket() {
    
        print("\n\n                  \(NSDate())")
        print("                  Connecting Socket...")
        self.isConnectingSocket = true
        socket.connect()

    }
   
    func hit(method URL : String, parameters : JSONDictionary = ["":""],
        
        successBlock: webServiceSuccess, failureBlock: webServiceFailure) {
            
            awaitingBlock = {
                
                self.socket.once(URL) { (data:[AnyObject], ack:SocketAckEmitter) -> Void in
                    
                    print("\n\n                  \(NSDate())")
                    print("                  RESPONSE FROM URL\n\n \(BASE_URL)/\(URL)");

                    print("\n\nRECEIVED DATA \n\n\n\(data)")
                    
                    if let response = data.first {
                        successBlock(json: JSON(response))
                    
                    } else {
                        successBlock(json: JSON(nilLiteral: ()))
                    }
                }
                
                print("\n\n                  \(NSDate())")
                print("                  HITTING URL\n\n \(BASE_URL)/\(URL)\n\n\n                  WITH PARAMETERS\n\n\(parameters)");
                print("\n\n\n                   WAITING FOR RESPONSE...");
                
                self.socket.emit(URL, parameters)
            }
            
            if self.isConnected {
            
                awaitingBlock!()
                awaitingBlock = nil
            
            } else {
            
                if !self.isConnectingSocket {
                    self.connectSocket()
                } else {
                    socket.reconnect()
                }
                
                //Temp //Socket Not Connected
//                failureBlock(error: NSError(domain: "", code: 0, userInfo: nil))
            }
    }
    
}
