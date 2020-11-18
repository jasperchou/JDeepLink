//
//  Router.swift
//  JDeepLink_Tests
//
//  Created by 周展鹏 on 2020/11/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import JDeepLink

class JDLDeepLinkRouterSpec: QuickSpec {
    override func spec() {
        describe("Initialization") {
            it("returns an instance") {
                expect(JDLDeepLinkRouter()).toNot(beNil())
            }
        }
        
        describe("Registering Routes") {
            let route = "table/book/:id"
            var router: JDLDeepLinkRouter = JDLDeepLinkRouter()
            beforeEach {
                router = JDLDeepLinkRouter.init()
            }
            
            it("registers a class for a route") {
                router.registerRoute(route, handlerClass: JDLRouteHandler.self)
                expect(router[route] == JDLRouteHandler.self).to(beTrue())
                expect(router.classesByRoute[route] == JDLRouteHandler.self).to(beTrue())
            }
            
            it("replaces a registered class handler with a block handler") {
                router[route] = { _ in }
                expect(router.classesByRoute[route]).to(beNil())
                expect(router.blocksByRoute[route]).toNot(beNil())
                
                router[route] = JDLRouteHandler.self
                expect(router.classesByRoute[route]).toNot(beNil())
                expect(router.blocksByRoute[route]).to(beNil())
            }
            
            it("does NOT register an empty route") {
                router[""] = JDLRouteHandler.self
                let handler: JDLRouteHandler.Type? = router[route]
                expect(handler).to(beNil())
            }
            
            it("removes a route when passing a nil handler") {
                router["table/book/:id"] = JDLRouteHandler.self
                expect(router[route] == JDLRouteHandler.self).to(beTrue())
            }
            
            it("does NOT trim routes before registering") {
                router["/table/book/:id \n"] = JDLRouteHandler.self
                expect(router[route] == JDLRouteHandler.self).to(beFalse())
            }
        }
        
        describe("Handling Routes") {
            let url = URL(string: "dlc://dlc.com/say/hello")!
            var router = JDLDeepLinkRouter()
            beforeEach {
                router = JDLDeepLinkRouter()
            }
            
            it("matches more specfic routes first when they are registered first") {
                waitUntil { (done) in
                    router["/say/hello"] = {
                        link in
                        expect(link.routeParameters).to(beEmpty())
                    }
                    router["/say/:word"] = {
                        _ in
                        fail("The wrong route was matched.")
                    }
                    let isHandled = router.handle(url: url) { (handled, error) in
                        expect(handled).to(beTrue())
                        expect(error).to(beNil())
                        done()
                    }
                    expect(isHandled).to(beTrue())
                }
            }
            
            it("continues looking for a match which will handle the route, even if the first match chooses not to handle it") {
                waitUntil { (done) in
                    router.registerRoute("/say/hello", handlerClass: JDLWontHandleRouteHandler.self)
                    var didMatchOnSecondRegistration = false
                    router["/say/:word"] = {
                        _ in
                        didMatchOnSecondRegistration = true
                    }
                    
                    let isHandled = router.handle(url: url) { (handled, error) in
                        expect(handled).to(beTrue())
                        expect(error).to(beNil())
                        done()
                    }
                    expect(didMatchOnSecondRegistration).to(beTrue())
                    expect(isHandled).to(beTrue())
                }
            }
            
            it("matches less specfic routes first when they are registered first") {
                waitUntil { (done) in
                    router["/say/:word"] = {
                        link in
                        expect(link.routeParameters["word"] as? String) == "hello"
                    }
                    router["/say/hello"] = {
                        _ in
                        fail("The wrong route was matched.")
                    }
                    let isHandled = router.handle(url: url) { (handled, error) in
                        expect(handled).to(beTrue())
                        expect(error).to(beNil())
                        done()
                    }
                    expect(isHandled).to(beTrue())
                }
            }
            
            it("produces an error when a URL has no matching route") {
                waitUntil { (done) in
                    let isHandled = router.handle(url: url) { (handled, error) in
                        expect(handled).to(beFalse())
                        expect((error! as NSError).code) == JDLErrorCodes.routeNotFound.rawValue
                        done()
                    }
                    expect(isHandled).to(beFalse())
                }
            }
            
            it("produces an error when a route handler does not specify a target view controller") {
                waitUntil { (done) in
                    router["/say/:word"] = JDLRouteHandler.self
                    let isHandled = router.handle(url: url) { (handled, error) in
                        expect(handled).to(beFalse())
                        expect((error! as NSError).code) == JDLErrorCodes.routeHandlerTargetNotSpecified.rawValue
                        done()
                    }
                    expect(isHandled).to(beFalse())
                }
            }
            
            it("handles an incoming user activity that is a web browsing activity type") {
                waitUntil { (done) in
                    let activity = NSUserActivity.init(activityType: NSUserActivityTypeBrowsingWeb)
                    activity.webpageURL = URL(string: "https://dlc.com/say/hello")!
                    router["/say/:word"] = { _ in }
                    let isHandled = router.handle(userActivity: activity) { (handled, error) in
                        expect(handled).to(beTrue())
                        expect(error).to(beNil())
                        done()
                    }
                    expect(isHandled).to(beTrue())
                }
            }
            
            it("does NOT handle an incoming user activity that is a NOT web browsing activity type") {
                let activity = NSUserActivity.init(activityType: "derpType")
                activity.webpageURL = URL(string: "https://dlc.com/say/hello")
                
                router["/say/:word"] = { _ in }
                let isHandled = router.handle(userActivity: activity, completionHandler: nil)
                expect(isHandled).to(beFalse())
            }
        }
    }
    
}
