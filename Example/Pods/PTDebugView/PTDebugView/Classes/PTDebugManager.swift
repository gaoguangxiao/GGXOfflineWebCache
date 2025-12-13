//
//  PTDebugManager.swift
//  PTDebugView
//
//  Created by 高广校 on 2025/2/27.
//

import Foundation

@objcMembers
public class PTDebugManager {
    
    public static func addLog(_ log : String, color: UIColor = .black) {
#if DEBUG
        let wStr = "\n-------\(Date.getCurrentDateStr("yyyy-MM-dd HH:mm:ss SSS"))日志-------\n" + log
        let att = NSAttributedString(string: wStr, attributes: [.foregroundColor: color])
        mAttributedString.insert(att, at: 0)
        ZKWLog.Log(wStr)
#endif
    }
}
