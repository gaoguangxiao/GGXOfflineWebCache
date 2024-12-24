//
//  GXURLSchemeHander.swift
//  RSReading
//
//  Created by 高广校 on 2023/11/8.
//

import Foundation
import WebKit
import GGXSwiftExtension

public struct WKURLSchemeWrapper: Hashable {
    //避免了多个 nil 的 task 被误认为是相等的情况
    let identifier = UUID()
    
    //手动管理移除
    var task: WKURLSchemeTask?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: WKURLSchemeWrapper, rhs: WKURLSchemeWrapper) -> Bool {
        return lhs.task === rhs.task
    }
}


open class GXURLSchemeHander: NSObject {
    private var dataTask: URLSessionDataTask?
    private static var session: URLSession?
    
    //This task has already been stopped 处理
    private var holdUrlSchemeTasks: Set<WKURLSchemeWrapper> = []
    
    public override init() {
        Self.updateSession()
    }
    
    private static func updateSession() {
        if Self.session != nil {
            return
        }
        let config = URLSessionConfiguration.default
        Self.session = URLSession(configuration: config)
    }
    
    func getUrlSchemeTasks(urlSchemeTask: WKURLSchemeTask) -> WKURLSchemeWrapper? {
        return holdUrlSchemeTasks.first{ $0.task === urlSchemeTask }
    }
    
    func addUrlSchemeTasks(urlSchemeTask: WKURLSchemeTask) {
        let wrapper = WKURLSchemeWrapper(task: urlSchemeTask)
        holdUrlSchemeTasks.insert(wrapper)
    }
    
    func removeUrlSchemeTasks(urlSchemeTask: WKURLSchemeTask) {
        guard let taskWrapper = self.getUrlSchemeTasks(urlSchemeTask: urlSchemeTask) else {
//            LogInfo("Task not found for stop: \(urlSchemeTask)")
            return
        }
        holdUrlSchemeTasks.remove(taskWrapper)
    }
}

@available(iOS 11.0, *)
extension GXURLSchemeHander: WKURLSchemeHandler{
    open func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        //        LogInfo("start urlSchemeTask: \(urlSchemeTask)")
        //1、标记网络处理任务
        self.addUrlSchemeTasks(urlSchemeTask: urlSchemeTask)
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: urlSchemeTask.request)
                guard let taskWrapper = self.getUrlSchemeTasks(urlSchemeTask: urlSchemeTask),
                      let task = taskWrapper.task else {
//                    LogInfo("return \(urlSchemeTask)")
                    return
                }
                task.didReceive(response)
                task.didReceive(data)
                task.didFinish()
                //2、移除任务
                self.holdUrlSchemeTasks.remove(taskWrapper)
                //4、debug数量
//                LogInfo("After: \(holdUrlSchemeTasks.count)")
            } catch {
                guard let taskWrapper = self.getUrlSchemeTasks(urlSchemeTask: urlSchemeTask),
                      let task = taskWrapper.task else {
//                    LogInfo("return \(urlSchemeTask)")
                    return
                }
                task.didFailWithError(error)
                //2、移除任务
                self.holdUrlSchemeTasks.remove(taskWrapper)
            }
        }
    }
    
    open func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        //3、stop标记的网络任务
//        LogInfo("stop urlSchemeTask: \(urlSchemeTask)")
        self.removeUrlSchemeTasks(urlSchemeTask: urlSchemeTask)
    }
}
