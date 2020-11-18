//
//  RegularExpression.swift
//  JDeepLink_Example
//
//  Created by 周展鹏 on 2020/11/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import JDeepLink
class RegularExpression: QuickSpec {
    override func spec() {
        describe("Matching named components") {
            it("should match named components without regex") {
                let expression = JDLRegularExpression.regularExpression("/hello/:do/:this/and/:that")!
                let matchResult = expression.matchResult("/hello/dovalue/thisvalue/and/thatvalue")
                expect(matchResult.match).to(beTrue())
                expect(matchResult.namedProperties as? [String: String]).to(equal([
                    "do": "dovalue",
                    "this": "thisvalue",
                    "that": "thatvalue"
                ]))
            }
            
            it("should match named components with regex") {
                let expression = JDLRegularExpression.regularExpression("/hello/:do([a-zA-Z]+)/:this([a-zA-Z]+)/and/:that([a-zA-Z]+)")!
                let matchResult = expression.matchResult("/hello/dovalue/thisvalue/and/thatvalue")
                expect(matchResult.match).to(beTrue())
                expect(matchResult.namedProperties as? [String: String]).to(equal([
                    "do": "dovalue",
                    "this": "thisvalue",
                    "that": "thatvalue"
                ]))
            }
            
            it("should match a mixture of with and without regex") {
                let expression = JDLRegularExpression.regularExpression("/hello/:do([a-zA-Z]+)/:this([a-zA-Z]+)/and/:that([a-zA-Z]+)")!
                let matchResult = expression.matchResult("/hello/dovalue/thisvalue/and/thatvalue")
                expect(matchResult.match).to(beTrue())
                expect(matchResult.namedProperties as? [String: String]).to(equal([
                    "do": "dovalue",
                    "this": "thisvalue",
                    "that": "thatvalue"
                ]))
            }
            
            it("should NOT match named components with regex that does not match") {
                let expression = JDLRegularExpression.regularExpression("/hello/:do([a-zA-Z]+)/:this([0-9]+)/and/:that([a-zA-Z]+)")!
                let matchResult = expression.matchResult("/hello/dovalue/thisvalue/and/thatvalue")
                expect(matchResult.match).to(beFalse())
            }
            
            it("should match named components with single character") {
                let expression = JDLRegularExpression.regularExpression("/hello/:a/:b/and/:c")!
                let matchResult = expression.matchResult("/hello/dovalue/thisvalue/and/thatvalue")
                expect(matchResult.match).to(beTrue())
            }
        }
    }
}
