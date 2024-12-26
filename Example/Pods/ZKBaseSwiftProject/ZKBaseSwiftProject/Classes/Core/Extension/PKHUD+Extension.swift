////
////  PKHUD+Extension.swift
////  HomePage
////
////  Created by Colin on 2018/8/17.
////  Copyright © 2018年 Putao. All rights reserved.
////
//
//import PKHUD
//
//public extension HUD {
//    static func loading(_ text: String = "加载中...") {
//        if !Thread.current.isMainThread {
//            DispatchQueue.main.sync {
//                HUD.show(.label(text))
//            }
//        } else {
//            HUD.show(.label(text))
//        }
//    }
//    
//    static func loading(_ text: String = "加载中...", on view: UIView?) {
//        if !Thread.current.isMainThread {
//            DispatchQueue.main.sync {
//                HUD.show(.label(text), onView: view)
//            }
//        } else {
//            HUD.show(.label(text), onView: view)
//        }
//    }
//    
//    static func flash(_ text: String = "",_ delay: TimeInterval = 1.5) {
//        if !Thread.current.isMainThread {
//            DispatchQueue.main.sync {
//                HUD.flash(.label(text), delay: delay)
//            }
//        } else {
//            HUD.flash(.label(text), delay: delay)
//        }
//    }
//    
//    static func flash(_ text: String = "",on view: UIView?,_ delay: TimeInterval = 1.5) {
//        if !Thread.current.isMainThread {
//            DispatchQueue.main.sync {
//                HUD.flash(.label(text), onView: view, delay: delay, completion: nil)
//            }
//        } else {
//            HUD.flash(.label(text), onView: view, delay: delay, completion: nil)
//        }
//    }
//}
