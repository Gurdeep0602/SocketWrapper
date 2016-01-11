//
//  ViewController.swift
//  SocketWrapper
//
//  Created by Gurdeep Singh on 04/01/16.
//  Copyright © 2016 Gurdeep Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        GSNetworking.hit(method: "GetDataOnSplash", successBlock: { (json) -> Void in
            
            let registrationScreen = json["registrationScreen"].dictionaryValue
            
            print(registrationScreen)
            
            }) { (error) -> Void in
             
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

