//
//  ViewController.swift
//  JDeepLink
//
//  Created by jasperchou on 11/16/2020.
//  Copyright (c) 2020 jasperchou. All rights reserved.
//

import UIKit
import JDeepLink
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let router = JDLDeepLinkRouter.init()
        router.registerRoute("/test") { (link) in
            print(link)
        }
        router.handle(url: URL(string: "xxx://test.com/test")!) { (isHandled, error) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}

