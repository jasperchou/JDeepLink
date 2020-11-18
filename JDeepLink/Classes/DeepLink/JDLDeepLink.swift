//
//  JPLDeepLink.swift
//  yilegou
//
//  Created by Jasper on 2020/8/18.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

public class JDLDeepLink: Equatable {
    private(set) var url: URL
    public internal(set) var queryParameters: [String: Any] = [:]
    public internal(set) var routeParameters: [String: Any] = [:]
    public var callbackURL: URL? {
        if let urlString = queryParameters[Self.CallbackURLKey] as? String {
            return URL(string: urlString)
        }
        return nil
    }
    
    public required init(url: URL) {
        self.url = url
        if let query = url.query {
            queryParameters = query.parameters()
        }
        var queryParameters = self.queryParameters
        do {
            if let fields = try (self.queryParameters[Self.JSONEncodedFieldNamesKey] as? String)?.decodedJSONObject() as? [String] {
                try queryParameters.forEach { (key, value) in
                    if fields.contains(key) {
                        if let value = value as? String {
                            queryParameters[key] = try value.decodedJSONObject() ?? value
                        }
                    }
                }
            }
        } catch {
            
        }
        self.queryParameters = queryParameters
    }
    
    public subscript(key: String) -> Any? {
        get {
            if let value = routeParameters[key] {
                return value
            }
            return queryParameters[key]
        }
        set {}
    }
    
    public static func == (lhs: JDLDeepLink, rhs: JDLDeepLink) -> Bool {
        if lhs.url == rhs.url {
            return true
        }
        return false
    }
    
    required convenience init(copy: JDLDeepLink) {
        self.init(url: copy.url)
        routeParameters = copy.routeParameters
    }
}
extension JDLDeepLink: JDLCopyable {
    func copy() -> Self {
        return type(of: self).init(url: url)
    }
}

extension JDLDeepLink {
    static let ErrorDomain = "com.usebutton.deeplink.error"
    static let CallbackURLKey = "dpl_callback_url"
    static let JSONEncodedFieldNamesKey = "dpl:json-encoded-fields"
}

extension JDLDeepLink: CustomStringConvertible {
    public var description: String {
        """
        < \(Self.self)  \n
        \t url: \(url) \n
        \t query: \(queryParameters) \n
        \t route: \(routeParameters) \n
        \t callbackURL: \(callbackURL?.description ?? "") \n
        >
        """
    }
}
