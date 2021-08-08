//
//  JDLDeepLinkRouter.swift
//  yilegou
//
//  Created by Jasper on 2020/8/20.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

public typealias JDLRouteHandlerBlock = (_ deepLink: JDLDeepLink) -> Void
public typealias JDLApplicationCanHandleDeepLinksBlock = () -> Bool
public typealias JDLRouteCompletionBlock = (_ handled: Bool, _ error: Error?) -> Void

public class JDLDeepLinkRouter: NSObject {
    private(set) var routes: NSMutableOrderedSet = .init()
    public private(set) var classesByRoute: [String: JDLRouteHandler.Type] = [:]
    public private(set) var blocksByRoute: [String: JDLRouteHandlerBlock] = [:]
    private var applicationCanHandleDeepLinkBlock: JDLApplicationCanHandleDeepLinksBlock?
    var applicationCanHandleDeepLinks: Bool {
        if let block = applicationCanHandleDeepLinkBlock {
            return block()
        }
        return true
    }
    
    public func registerRoute(_ route: String, handlerClass: JDLRouteHandler.Type) {
        if route.isEmpty {
            return
        }
        routes.add(route)
        blocksByRoute.removeValue(forKey: route)
        classesByRoute[route] = handlerClass
    }
    
    public func registerRoute(_ route: String, block: @escaping JDLRouteHandlerBlock) {
        routes.add(route)
        classesByRoute.removeValue(forKey: route)
        blocksByRoute[route] = block
    }
    
    @discardableResult
    public func handle(url: URL, completionHandler: JDLRouteCompletionBlock?) -> Bool {
        if !applicationCanHandleDeepLinks {
            completeRoute(handled: false, err: nil, completionHandler: completionHandler)
            return false
        }
        
        var handled = false
        var err: Error?
        var deepLink: JDLDeepLink?
        for route in routes {
            if let route = route as? String, let matcher = JDLRouteMatcher.matcher(route: route) {
                deepLink = matcher.deepLink(url: url)
                if let deepLink = deepLink {
                    do {
                        handled = try handle(route: route, deepLink: deepLink)
                        if handled {
                            break
                        }
                    } catch {
                        err = error
                    }
                    
                }
            }
        }
        if deepLink == nil {
            err = NSError.init(domain: JDLDeepLink.ErrorDomain, code: JDLErrorCodes.routeNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "The passed URL does not match a registered route."])
        }
        completeRoute(handled: handled, err: err, completionHandler: completionHandler)
        return handled
    }
    
    public func handle(userActivity: NSUserActivity, completionHandler: JDLRouteCompletionBlock?) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            return handle(url: userActivity.webpageURL!, completionHandler: completionHandler)
        }
        return false
    }
    
    func handle(route: String, deepLink: JDLDeepLink) throws -> Bool {
        if let handler = blocksByRoute[route] {
            handler(deepLink)
            return true
        }
        if let handlerClass = classesByRoute[route] {
            let handler = handlerClass.init()
            if !handler.shouldHandle(deepLink) {
                return false
            }
            
            if let target = handler.targetViewController,
                let presentingViewController = handler.viewControllerForPresenting(deepLink) {
                target.configure(deepLink)
                handler.present(target: target, presentingViewController: presentingViewController)
            } else {
                let error = NSError.init(domain: JDLDeepLink.ErrorDomain, code: JDLErrorCodes.routeHandlerTargetNotSpecified.rawValue, userInfo: [NSLocalizedDescriptionKey: "The matched route handler does not specify a target view controller."])
                throw error
            }
        }
        return false
    }
    
    func completeRoute(handled: Bool, err: Error?, completionHandler: JDLRouteCompletionBlock?) {
        DispatchQueue.main.async {
            if let completionHandler = completionHandler {
                completionHandler(handled, err)
            }
        }
    }
    
    public subscript(route: String) -> JDLRouteHandler.Type? {
        get {
            classesByRoute[route]
        }
        set {
            if let newValue = newValue {
                registerRoute(route, handlerClass: newValue)
            } else {
                self.routes.remove(route)
                self.classesByRoute.removeValue(forKey: route)
                self.blocksByRoute.removeValue(forKey: route)
            }
        }
    }
    
    public subscript(route: String) -> JDLRouteHandlerBlock? {
        get {
            blocksByRoute[route]
        }
        set {
            if let newValue = newValue {
                registerRoute(route, block: newValue)
            } else {
                self.routes.remove(route)
                self.classesByRoute.removeValue(forKey: route)
                self.blocksByRoute.removeValue(forKey: route)
            }
        }
    }
}
