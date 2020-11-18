//
//  JDLRouteHandler.swift
//  yilegou
//
//  Created by Jasper on 2020/8/20.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

public class JDLRouteHandler {
    public var preferModalPresentation = false
    public var targetViewController: (JDLTargetViewControllerProtocol & UIViewController)? = nil
    required init() {}
    
    public func shouldHandle(_ deepLink: JDLDeepLink) -> Bool {
        return true
    }
    
    public func viewControllerForPresenting(_ deepLink: JDLDeepLink) -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    public func present(target: (UIViewController & JDLTargetViewControllerProtocol), presentingViewController: UIViewController) {
        if preferModalPresentation || presentingViewController.isKind(of: UINavigationController.self) {
            presentingViewController.present(target, animated: false, completion: nil)
        } else if presentingViewController.isKind(of: UINavigationController.self) {
            if let nav = presentingViewController as? UINavigationController {
                nav.place(target: target)
            }
        }
    }
}
