// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import JDeepLink

class JDLDeepLinkSpec: QuickSpec {
    override func spec() {
        describe("Initialization") {
            it("returns a deep link when passed a URL") {
                if let url = URL(string: "dpl://dpl.io/ride/book/abc123?partner=uber") {
                    let link = JDLDeepLink.init(url: url)
                    expect(link.url) == url
                    expect(link.queryParameters as? [String : String]) == ["partner": "uber"]
                }
            }
            it("has a callback url when a dpl_callback_url is present") {
                let callbackURLString = "btn://dpl.io/say/hi"
                let URLString = "dpl://dpl.io/say/hello?dpl_callback_url=\(callbackURLString.addingPercentEscapes()!)"
                let link = JDLDeepLink.init(url: URL.init(string: URLString)!)
                expect(link.callbackURL?.absoluteString) == callbackURLString
            }
            
            it("should favor route parameters over query parameters for indexed subscripting") {
                let url = URL(string: "dpl://dpl.io/ride/book/abc123?partner=uber")
                let link = JDLDeepLink.init(url: url!)
                link.routeParameters = ["partner": "not-uber"]
                expect(link["partner"] as? String) == "not-uber"
            }
            
            it("preserves key only query items") {
                let url = URL(string: "seamlessapp://menu?293147")
                let link = JDLDeepLink.init(url: url!)
                expect(link.queryParameters["293147"] as? String) == ""
                expect(link.url.absoluteString) == "seamlessapp://menu?293147"
            }
        }
        
        describe("Coping") {
            let url = URL(string: "dpl://dpl.io/ride/abc123?partner=uber")
            it("returns an immutable deep link via copy") {
                let link1 = JDLDeepLink.init(url: url!)
                let link2 = link1.copy()

                expect(link2.url) == link1.url
                expect(link2.callbackURL).to(beNil())
                expect(link1.callbackURL).to(beNil())
//                expect(link2.queryParameters) == link1.queryParameters
            }
        }
        
        describe("Equality") {
            let url1 = URL(string: "dpl://dpl.io/ride/abc123?partner=uber")!
            let url2 = URL(string: "dpl://dpl.io/book/def456?partner=airbnb")!
            it("two identical deeps links are equal") {
                let link1 = JDLDeepLink.init(url: url1)
                let link2 = JDLDeepLink.init(url: url1)
                expect(link1) == link2
            }
            
            it("two different deep links are inequal") {
                let link1 = JDLDeepLink.init(url: url1)
                let link2 = JDLDeepLink.init(url: url2)
                expect(link1) != link2
            }
            
        }
//        describe("these will fail") {
//
//            it("can do maths") {
//                expect(1) == 2
//            }
//                expect(link.callbackURL) != nil
//            it("can read") {
//                expect("number") == "string"
//            }
//
//            it("will eventually fail") {
//                expect("time").toEventually( equal("done") )
//            }
//
//            context("these will pass") {
//
//                it("can do maths") {
//                    expect(23) == 23
//                }
//
//                it("can read") {
//                    expect("🐮") == "🐮"
//                }
//
//                it("will eventually pass") {
//                    var time = "passing"
//
//                    DispatchQueue.main.async {
//                        time = "done"
//                    }
//
//                    waitUntil { done in
//                        Thread.sleep(forTimeInterval: 0.5)
//                        expect(time) == "done"
//
//                        done()
//                    }
//                }
//            }
//        }
    }
}
