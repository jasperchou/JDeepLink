//
//  JDLRegularExpression.swift
//  yilegou
//
//  Created by Jasper on 2020/8/18.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

class JDLRegularExpression: NSRegularExpression {
    static let JDLNameGroupComponentPattern = ":[a-zA-Z0-9-_]+[^/]*"
    static let JDLRouteParameterPattern = ":[a-zA-Z0-9-_]+"
    static let JDLURLParameterPattern = "([^/]+)"
    
    var groupNames = [String]()
    
    static func regularExpression(_ pattern: String) -> JDLRegularExpression? {
        do {
            return try JDLRegularExpression.init(pattern: pattern, options: [])
        } catch {}
        return nil
    }
    
    override init(pattern: String, options: NSRegularExpression.Options = []) throws {
        let cleanPattern = try Self.removeNamedGroups(pattern)
        try super.init(pattern: cleanPattern, options: [])
        groupNames = try Self.nameGroups(pattern)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func matchResult(_ string: String) -> JDLMatchResult {
        let matches = self.matches(in: string, options: [], range: NSRange.init(location: 0, length: string.count))
        let matchResult = JDLMatchResult()
        if matches.isEmpty {
            return matchResult
        }
        matchResult.match = true
        
        var routeParameters = [String: String]()
        for result in matches {
            for i in 1 ..< result.numberOfRanges {
                if i > groupNames.count {
                    break
                }
                let name = self.groupNames[i - 1]
                let range = result.range(at: i)
                let value = String(string[Range.init(range, in: string)!])
                routeParameters[name] = value
            }
        }
        matchResult.namedProperties = routeParameters
        return matchResult
    }
}

// Named Group Helpers
extension JDLRegularExpression {
    static func nameGroupTokens(_ string: String) throws -> [String] {
        let componentRegex = try NSRegularExpression(pattern: JDLNameGroupComponentPattern, options: [])
        let matches = componentRegex.matches(in: string, options: [], range: .init(location: 0, length: string.count))
        var namedGroupTokens = [String]()
        for result in matches {
            let range = Range<String.Index>.init(result.range, in: string)
            let namedGroupToken = string[range!]
            namedGroupTokens.append(String(namedGroupToken))
        }
        return namedGroupTokens
    }
    
    static func removeNamedGroups(_ string: String) throws -> String {
        var modifiedStr = string
        
        let namedGroupExpressions = try Self.nameGroupTokens(string)
        let parameterRegex = try NSRegularExpression(pattern: JDLRouteParameterPattern, options: [])
        for namedExpression in namedGroupExpressions {
            var replacementExpression = namedExpression
            if let foundGroupName = parameterRegex.matches(in: namedExpression, options: [], range: .init(location: 0, length: namedExpression.count)).first {
                let stringToReplace = namedExpression[Range.init(foundGroupName.range, in: namedExpression)!]
                replacementExpression = replacementExpression.replacingOccurrences(of: stringToReplace, with: "")
            }
            if replacementExpression.isEmpty {
                replacementExpression = JDLURLParameterPattern
            }
            modifiedStr = modifiedStr.replacingOccurrences(of: namedExpression, with: replacementExpression)
        }
        if !modifiedStr.isEmpty && !(modifiedStr.first == "/") {
            modifiedStr = "^" + modifiedStr
        }
        modifiedStr = modifiedStr + "$"
        
        return modifiedStr
    }
    
    static func nameGroups(_ string: String) throws -> [String] {
        var groupNames: [String] = []
        
        let namedGroupExpressions = try Self.nameGroupTokens(string)
        let parameterRegex = try NSRegularExpression(pattern: JDLRouteParameterPattern, options: [])
        for namedExpression in namedGroupExpressions {
            let componentMatches = parameterRegex.matches(in: namedExpression, options: [], range: .init(location: 0, length: namedExpression.count))
            if let foundGroupName = componentMatches.first {
                let stringToReplace = namedExpression[Range.init(foundGroupName.range, in: namedExpression)!]
                let variableName = stringToReplace.replacingOccurrences(of: ":", with: "")
                groupNames.append(variableName)
            }
        }
        return groupNames
    }
}

