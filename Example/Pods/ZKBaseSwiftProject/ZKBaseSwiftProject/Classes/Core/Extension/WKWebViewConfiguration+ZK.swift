//
//  WKWebViewConfiguration+ZK.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2024/1/4.
//

import Foundation
import WebKit

@available(iOS 11.0, *)
public extension WKWebViewConfiguration {
    func addProxyConfig(handler: WKURLSchemeHandler?) {
        _ = hookWKWebView
        httpSchemes.forEach {
            setURLSchemeHandler(handler, forURLScheme: $0)
        }
    }
}
