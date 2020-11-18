//
//  String+JDL.swift
//  yilegou
//
//  Created by Jasper on 2020/8/18.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

extension String {
    func trimPath() -> String {
        let trimSet = NSMutableCharacterSet(charactersIn: "/")
        trimSet.formUnion(with: .whitespacesAndNewlines)
        return trimmingCharacters(in: trimSet as CharacterSet)
    }
}

// MARK: QUERY
extension String {
    func queryString(_ parameters: [String: Any]) -> String {
        var query = ""
        parameters.forEach { (k, v) in
            if let k = k.addingPercentEscapes(), let v = "\(v)".addingPercentEscapes() {
                query += "\(k):\(v)&"
            }
        }
        if !query.isEmpty {
            let index = query.index(query.endIndex, offsetBy: -1)
            return String.init(query.prefix(upTo: index))
        }
        return query
    }
    
    func parameters() -> [String: String] {
        let params = components(separatedBy: "&")
        var paramsMap = [String: String]()
        params.forEach {
            let pairs = $0.components(separatedBy: "=")
            if pairs.count == 2 {
                if let key = pairs[0].replacingPercentEscapes(), let value = pairs[1].replacingPercentEscapes() {
                    paramsMap[key] = value
                }
            } else if pairs.count == 1 {
                if let key = pairs[0].replacingPercentEscapes() {
                    paramsMap[key] = ""
                }
            }
        }
        return paramsMap
    }
}

// MARK: JDLJSON
extension String {
    func decodedJSONObject() throws -> Any? {
        let jsonData = data(using: .utf8)
        let object = try JSONSerialization.jsonObject(with: jsonData!, options: [])
        return object
    }
    
    static func string(_ jsonObject: Any) throws -> String? {
        if JSONSerialization.isValidJSONObject(jsonObject) {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            return String.init(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}

// MARK: URL Encoding/Decoding
extension String {
    func addingPercentEscapes() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .init(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"))
    }
    
    func replacingPercentEscapes() -> String? {
        return self.removingPercentEncoding
    }
}
