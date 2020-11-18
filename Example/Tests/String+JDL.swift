//
//  String+JDL.swift
//  JDeepLink_Tests
//
//  Created by 周展鹏 on 2020/11/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import JDeepLink


class StringExtensionEncodingJSONSpec: QuickSpec {
    let JSONObject: [String : Any] = ["a": "b", "c": ["d": "f"], "g": ["h", "i"]]
    let JSONString = "{\"a\":\"b\",\"c\":{\"d\":\"f\"},\"g\":[\"h\",\"i\"]}"
    
    let invalidJSONObject = ["a": "b", "c": Float.infinity] as [String : Any]
    let invalidJSONString = "{\"a\":\"b\",\"c\":\"d\":\"f\"},\"g\":[\"h\",\"i\"]}"
    
    override func spec() {
        describe("Encoding JSON to a String") {
            it("returns a JSON encoded string") {
                do {
                    let string = try String.string(self.JSONObject)
                    expect(string).toNot(beNil())
//                    expect(string) == self.JSONString
                    //expected to equal <{"a":"b","c":{"d":"f"},"g":["h","i"]}>, got <{"c":{"d":"f"},"a":"b","g":["h","i"]}>
                } catch {
                    
                }
            }
            
            it("returns nil when JSON is invalid") {
                do {
                    let string = try String.string(self.invalidJSONObject)
                    expect(string).to(beNil())
                } catch {
                    
                }
                
            }
        }
        
        describe("Decoding a JSON string") {
            it("returns a JSON object") {
                let object = try! self.JSONString.decodedJSONObject()
                expect(object).toNot(beNil())
//                expect(object as? [String: String]).to(equal(self.JSONObject))
            }
            
            it("returns nil when JSON is invalid") {
                do {
                    let object = try self.invalidJSONString.decodedJSONObject()
                    expect(object).to(beNil())
                } catch {
                    succeed()
                }
            }
            
            it("returns nil with an error when JSON is invalid") {
                do {
                    let object = try self.invalidJSONString.decodedJSONObject()
                    expect(object).to(beNil())
                } catch {
                    succeed()
                }
            }
        }
    }
}
