//
//  RouteMatcher.swift
//  JDeepLink_Tests
//
//  Created by 周展鹏 on 2020/11/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import JDeepLink

class RouteMatcherSpec: QuickSpec {
    func fullURL(_ path: String) -> URL {
        return URL(string: "dpl://dpl.com\(path)")!
    }
    override func spec() {
        describe("Initialization") {
            it("creates an instance with a route") {
                let routeMatcher = JDLRouteMatcher.init(route: "/thing/:another")
                expect(routeMatcher).toNot(beNil())
            }
            
            it("does not create an instance with no route") {
                let routeMatcher = JDLRouteMatcher.init(route: "")
                expect(routeMatcher).to(beNil())
            }
        }
        
        describe("Matching Routes") {
            it("returns a deep link when a URL matches a route") {
                let matcher = JDLRouteMatcher.init(route: "/table/book")!
                let url = self.fullURL("/table/book")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link!.routeParameters.isEmpty).to(beTrue())
            }
            
            it("returns a deep link when a URL matches a host") {
                let matcher = JDLRouteMatcher.matcher(route: "dpl.com")!
                let url = self.fullURL("")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link?.routeParameters.isEmpty).to(beTrue())
            }
            
            it("does NOT return a deep link when a host does NOT match the URL host") {
                let matcher = JDLRouteMatcher.init(route: "dpl2.com")!
                let url = self.fullURL("")
                let link = matcher.deepLink(url: url)
                expect(link).to(beNil())
            }
            
            it("does NOT return a deep link when a host does NOT match and path does match") {
                let matcher = JDLRouteMatcher.init(route: "dpl2.com/table/:id")!
                let url = self.fullURL("/table/abc123")
                let link = matcher.deepLink(url: url)
                expect(link).to(beNil())
            }
            
            it("returns a deep link when a URL matches a host and path") {
                let matcher = JDLRouteMatcher.init(route: "dpl.com/table")!
                let url = self.fullURL("/table")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
            }
            
            it("does NOT return a deep link when a host matches and a path does NOT match") {
                let matcher = JDLRouteMatcher.init(route: "dpl.com/ride")!
                let url = self.fullURL("/table")
                let link = matcher.deepLink(url: url)
                expect(link).to(beNil())
            }

            it("returns a deep link when a URL matches a parameterized route") {
                let matcher = JDLRouteMatcher.init(route: "dpl.com/table/book/:id")!
                let url = self.fullURL("/table/book/abc123")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
            }
            
            it("does NOT return a deep link when the URL and route don't match") {
                let matcher = JDLRouteMatcher.init(route: "/table/book")!
                let url = self.fullURL("/table/book/abc123")
                let link = matcher.deepLink(url: url)
                expect(link).to(beNil())
            }
            
            it("does NOT return a deep link when the URL and parameterized route dont match") {
                let matcher = JDLRouteMatcher.init(route: "/table/book/:id")!
                let url = self.fullURL("/table/book")
                let link = matcher.deepLink(url: url)
                expect(link).to(beNil())
            }
            
            it("returns a deep link with route parameters when a URL matches a parameterized route") {
                let matcher = JDLRouteMatcher.init(route: "/table/book/:id/:time")!
                let url = self.fullURL("/table/book/abc123/1418931000")
                let link = matcher.deepLink(url: url)
                expect(link!.routeParameters["id"] as? String) == "abc123"
                expect(link!.routeParameters["time"] as? String) == "1418931000"
            }
            
            it("returns a deep link with route parameters when a URL matches a parameterized route for a specific host") {
                let matcher = JDLRouteMatcher.init(route: "dpl.com/table/book/:id/:time")!
                let url = self.fullURL("/table/book/abc123/1418931000")
                let link = matcher.deepLink(url: url)
                expect(link!.routeParameters["id"] as? String) == "abc123"
                expect(link!.routeParameters["time"] as? String) == "1418931000"
            }
            
            it("matches a wildcard deep link") {
                let matcher = JDLRouteMatcher.init(route: ".*")!
                let url = self.fullURL("/table/book/abc123/1418931000")
                let url2 = self.fullURL("/abc123")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link!.routeParameters.isEmpty).to(beTrue())
            
                let link2 = matcher.deepLink(url: url2)
                expect(link2).toNot(beNil())
                expect(link2!.routeParameters.isEmpty).to(beTrue())
            }
            
            it("matches a wildcard deeplink to route parameters") {
                let matcher = JDLRouteMatcher.init(route: "/table/:path(.*)")!
                let url = self.fullURL("/table/some/path/which/should/be/in/route/parameters")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link!.routeParameters["path"] as? String) == "some/path/which/should/be/in/route/parameters"
            }
            
            it("matches URLs with commas") {
                let matcher = JDLRouteMatcher.init(route: "TenDay/:weird_comma_path_thing")!
                let url = URL(string: "twcweather://TenDay/33.89,-84.46?aw_campaign=com.weather.TWC.TWCWidget")!
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link!.routeParameters["weird_comma_path_thing"] as? String) == "33.89,-84.46"
            }
            
            it("returns a deep link with route parameters when a URL matches a parameterized regex route") {
                let matcher = JDLRouteMatcher.init(route: "/table/:table([a-zA-Z]+)/:id([0-9]+)")!
                let url = self.fullURL("/table/randomTableName/109")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link!.routeParameters["table"] as? String) == "randomTableName"
                expect(link!.routeParameters["id"] as? String) == "109"
            }
            
            it("allows some named groups to be expressed with regex and not others") {
                let matcher = JDLRouteMatcher.init(route: "/table/:table([a-zA-Z]+)/[a-z]+/:other([a-z]+)/:thing")!
                let url = self.fullURL("/table/anytable/anychair/another/anything")
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link!.routeParameters as? [String: String]) == [
                    "table": "anytable",
                    "other": "another",
                    "thing": "anything"
                ]
            }
            
            it("does NOT return a deep link when the URL path does not match regex table parameter") {
                let matcher = JDLRouteMatcher.init(route: "/table/:table([a-zA-Z]+)/:id([0-9])")!
                let url = self.fullURL("/table/table_name/109")
                let link = matcher.deepLink(url: url)
                expect(link).to(beNil())
            }
            
            it("does NOT match partial strings") {
                let matcher = JDLRouteMatcher.init(route: "me")!
                let url = self.fullURL("home")
                let link = matcher.deepLink(url: url)
                expect(link).to(beNil())
            }
            
            it("does NOT match partial strings") {
                let matcher = JDLRouteMatcher.init(route: ":host")!
                let url = URL(string: "scheme://myrandomhost?param1=value1&param2=value2")!
                let link = matcher.deepLink(url: url)
                expect(link).toNot(beNil())
                expect(link!.queryParameters.count) == 2
                expect(link!.routeParameters["host"] as? String) == "myrandomhost"
            }
        }
        
        // MARK: Matching on Schemes
        describe("Matching on Schemes") {
            var url1 = URL(string: "derp://dpl.io/say/hello")!
            var url2 = URL(string: "foo://dpl.io/say/hello")!
            
            beforeEach {
                url1 = URL(string: "derp://dpl.io/say/hello")!
                url2 = URL(string: "foo://dpl.io/say/hello")!
            }
            
            it("allows any scheme if not specified in the route") {
                let matcher = JDLRouteMatcher.matcher(route: "/say/hello")!
                let link = matcher.deepLink(url: url1)
                expect(link).toNot(beNil())
                
                let link2 = matcher.deepLink(url: url2)
                expect(link2).toNot(beNil())
            }
            
            it("matches a url with a scheme specific route") {
                let matcher = JDLRouteMatcher.matcher(route: "derp://(.*)/say/hello")!
                let link = matcher.deepLink(url: url1)
                expect(link).toNot(beNil())
            }
            
            it("does NOT match a url with a different scheme than the route") {
                let matcher = JDLRouteMatcher.matcher(route: "derp://(.*)/say/hello")!
                let link = matcher.deepLink(url: url2)
                expect(link).to(beNil())
            }
        }
    }
    
}
