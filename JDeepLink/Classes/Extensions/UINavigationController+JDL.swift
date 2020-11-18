//
//  UINavigationController+JDL.swift
//  yilegou
//
//  Created by Jasper on 2020/8/18.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

//routing
extension UINavigationController {
    func place(target: UIViewController) {
        if viewControllers.contains(target) {
            popToViewController(target, animated: false)
        } else {
            for controller in viewControllers {
                if controller.isKind(of: type(of: target)) {
                    popToViewController(controller, animated: false)
                    popViewController(animated: false)
                    if controller === topViewController {
                        setViewControllers([target], animated: false)
                    }
                }
                break
            }
            if !(topViewController === target) {
                pushViewController(target, animated: false)
            }
        }
    }
}
