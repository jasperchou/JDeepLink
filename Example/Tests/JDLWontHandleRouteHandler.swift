//
//  JDLWontHandleRouteHandler.swift
//  JDeepLink_Example
//
//  Created by 周展鹏 on 2020/11/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
@testable import JDeepLink

public class JDLWontHandleRouteHandler: JDLRouteHandler {
    public override func shouldHandle(_ deepLink: JDLDeepLink) -> Bool {
        return false
    }
}
