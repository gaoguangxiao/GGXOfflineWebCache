//
//  WKWebView+Extension.swift
//  GGXSwiftExtension
//
//  Created by 高广校 on 2023/12/29.
//

import Foundation
import WebKit

//数据存储
//@available(iOS 9.0, *)
public extension WKWebsiteDataStore {
 
    class func removeWebsiteDataStore() {
        //移除所有WKWebsiteDataStore的缓存
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        let sincesDate = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: sincesDate) {
            print("清理数据")
        }
    }
    
    class func closeWebviewStorage(handle: ((String) -> ())?) {
        let dataSouce = WKWebsiteDataStore.default()
        dataSouce.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) { handle?("清除成功\(record)") }
            }
        }
    }
    
}
