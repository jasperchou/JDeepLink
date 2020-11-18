//
//  JDLRouteMatcher.swift
//  yilegou
//
//  Created by Jasper on 2020/8/20.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

class JDLRouteMatcher {
    var scheme: String? = nil
    var regexMatcher: JDLRegularExpression!
    static func matcher(route: String) -> JDLRouteMatcher? {
        JDLRouteMatcher.init(route: route)
    }
    
    func deepLink(url: URL) -> JDLDeepLink? {
        let deepLink = JDLDeepLink.init(url: url)
        let deepLinkString = "\(deepLink.url.host ?? "")\(deepLink.url.path)"
        if let scheme = scheme, !scheme.isEmpty, scheme != deepLink.url.scheme {
            return nil
        }
        
        let matchResult = regexMatcher.matchResult(deepLinkString)
        if !matchResult.match {
            return nil
        }
        deepLink.routeParameters = matchResult.namedProperties
        return deepLink
    }
    
    init?(route: String) {
        if route.isEmpty {
            return nil
        }
        
        let parts = route.components(separatedBy: "://")
        scheme = parts.count > 1 ? parts.first : nil
        // route 不为空，last 肯定有值
        regexMatcher = JDLRegularExpression.regularExpression(parts.last!)
    }
}
