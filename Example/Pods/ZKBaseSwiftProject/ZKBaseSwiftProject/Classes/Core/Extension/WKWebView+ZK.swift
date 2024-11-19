//
//  WKWebView+ZK.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2024/1/4.
//

import Foundation
import WebKit

let httpSchemes = ["http", "https"]

@available(iOS 11.0, *)
var hookWKWebView: () = {
    guard let origin = class_getClassMethod(WKWebView.self, #selector(WKWebView.handlesURLScheme(_:))),
          let hook = class_getClassMethod(WKWebView.self, #selector(WKWebView._handlesURLScheme(_:))) else {
        return
    }
    method_exchangeImplementations(origin, hook)
}()

@available(iOS 11.0, *)
fileprivate extension WKWebView {
    @objc static func _handlesURLScheme(_ urlScheme: String) -> Bool {
        if httpSchemes.contains(urlScheme) {
            return false
        }
        return Self.handlesURLScheme(urlScheme)
    }
}
