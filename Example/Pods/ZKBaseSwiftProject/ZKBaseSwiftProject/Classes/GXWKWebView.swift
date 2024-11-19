//
//  GXWKWebView.swift
//  SwiftUiCreate
//
//  Created by 高广校 on 2023/11/22.
//

import SwiftUI
import WebKit


//定义JS交互闭包
public typealias WKScriptMessageClosure = (WKScriptMessage,Int) -> Void

//UIViewRepresentable 遵循`View`协议，SwiftUI，可以将任何遵循UIViewRepresentable的结构体都当做一般swiftUI视图处理
//必须有协调器
//其生命周期 onAppear->makeCoordinator【协调器】->makeUIView->updateUIView->dis
//用`UIViewRepresentable`包装UIkit视图，使可以在swiftUI中使用，必须实现下面`makeUIView(context: Context)`
//和`updateUIView(_ uiView: WKWebView, context: Context)`方法
@available(iOS 13.0, *)
public struct GXWKWebView: UIViewRepresentable {
    
    //构建遵循`UIViewRepresentable`协议的结构体，都必须构建属于其的协调器，用于处理业务，因为SwiftUI没有控制器概念，因此可以将无法剥离的业务放在协调器中
    let coordinator: GXWKWebViewCoordinator = GXWKWebViewCoordinator()
    
    //执行回调
    public var scriptMessageClose: WKScriptMessageClosure?
    
    public var url: String?
    
    private var webView: WKWebView = {
        print("执行WKWebView初始化")
        let conf = WKWebViewConfiguration()
        let preferences = WKPreferences.init()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let pagePreferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            pagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
            //                pagePreferences.preferredContentMode = .desktop
        }
        conf.defaultWebpagePreferences = pagePreferences
        conf.preferences = preferences
        conf.userContentController = WKUserContentController()
        //配置
        conf.allowsInlineMediaPlayback = true
        conf.allowsAirPlayForMediaPlayback = false
        let webView = WKWebView(frame: .zero, configuration: conf)
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
        webView.scrollView.bounces = false
        webView.allowsLinkPreview = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        return webView
    }()
    
    public init(url: String? = nil) {
        self.url = url
    }
    //    在 makeUIView(context:) 之前调用 makeCoordinator()并将 Coordinator 对象存储在context.coordinator 中。
    //     创建一个包装UIKit视图实例，只会调用一次
    public func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = url, let requetURL = URL(string: url)  {
            uiView.load(URLRequest(url: requetURL,cachePolicy: .reloadIgnoringLocalCacheData))
        }
    }
    
    public func makeCoordinator() -> GXWKWebViewCoordinator {
        return coordinator
    }
}



// MARK: 提供JS交互方法
@available(iOS 13.0, *)
public extension GXWKWebView {
    
    //自定义UA
    func setUA(customUserAgent: String) -> Self {
        self.webView.customUserAgent = customUserAgent
        return self
    }
    
    func addUserScript(forSource source: String) -> Self {
        let userScript: WKUserScript = WKUserScript.init(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)
        return self
    }
    
    func addScriptMessage(name: String,jsBridge:@escaping WKScriptMessageClosure) -> Self {
        let userContentController = webView.configuration.userContentController
        if #available(iOS 14, *){
            let messageBridge = GXMessageBridge(scriptWithReplyDelegate: coordinator)
            userContentController.addScriptMessageHandler(messageBridge, contentWorld: .page, name: name)
        } else {
            let messageBridge = GXMessageBridge(coordinator)
            userContentController.add(messageBridge, name: name)
        }
        coordinator.scriptMessageClose = jsBridge
        return self
    }
    
    func evaluateJavaScript(javaScriptString: String) -> Self {
        addTaskToMainThread {
            self.webView.evaluateJavaScript(javaScriptString) { (dataa, error) in
                
            }
        }
        return self
    }
}

// MARK: 协调器
open class GXWKWebViewCoordinator: NSObject {
    
    public var scriptMessageClose: WKScriptMessageClosure?
    
    
}

extension GXWKWebViewCoordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (result, error) in
            print("didFinish:\(String(describing: result ?? ""))")
        }
    }
}

extension GXWKWebViewCoordinator: WKScriptMessageHandler , WKScriptMessageHandlerWithReply{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("old iOS 14---\(message.body)")
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        //        XXX.handJS.re
        if let close = self.scriptMessageClose {
            close(message,0)
        }
        
        //完成回调
        //        replyHandler(,)
        //        print("---\(message.body)")
    }
    
    //处理JS->iOS 交给bridge处理
}
