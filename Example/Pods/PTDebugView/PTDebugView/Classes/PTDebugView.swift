//
//  PTDebugView.swift
//  KidReading
//
//  Created by zoe on 2019/6/17.
//  Copyright © 2019 putao. All rights reserved.
//  输出web log日志

import Foundation
import GGXSwiftExtension
import SnapKit
import UIKit

public enum PTDebugViewButtonEvent {
    case ChangeUrl(PTDebugView)
    case ReloadWeb
    case pkgAction(Int) //离线包操作
    case otherAction(Int) //其他按钮操作
}

//PTShowCorner
public enum TapShowCorner {
    case leftBottom
    case rightUp
}

public typealias DebugButtonEvent = (_ event: PTDebugViewButtonEvent) -> Void

var mAttributedString :NSMutableAttributedString = NSMutableAttributedString(string: "")//日志富文本

public class PTDebugView: UIView {
    
    private var debugTextView =  UITextView.init()
    
    private var clickButtonEvent :((PTDebugViewButtonEvent)->Void)? = nil
    
    public var reloadButtonEvent :DebugButtonEvent?
    
    public var headInfoLog: String?
    
    /// 录音按钮龙智
    public var recordLogBtn: UIButton?
//    public var baseWebUrl: String = ""
    
    public var tapCorner: TapShowCorner = .leftBottom
    
    var actionBtnTag = 0
    
    public static func addLog(_ log : String, color: UIColor = .black) {
#if DEBUG
        let wStr = "\n-------\(Date.getCurrentDateStr("yyyy-MM-dd HH:mm:ss SSS"))日志-------\n" + log
        let att = NSAttributedString(string: wStr, attributes: [.foregroundColor: color])
        mAttributedString.insert(att, at: 0)
        ZKWLog.Log(wStr)
#endif
    }
    public func supportIn(superView: UIView ,apiURL: String = "", debugEvent :@escaping (PTDebugViewButtonEvent)->Void) {
        superView.addSubview(self)
        self.clickButtonEvent = debugEvent
        self.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
//            maker.top.equalToSuperview()
//            maker.left.bottom.right.equalToSuperview()
        }
//        defaultApiUrl = apiURL
        
//        mAttributedString = NSMutableAttributedString(string: "")

        self.setUI()
        self.isHidden = true
//        self.backgroundColor = .red
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickEvent))
        tap.numberOfTapsRequired = 6
        //        tap.numberOfTouchesRequired = 2
        superView.addGestureRecognizer(tap)
        
    }
    
    @objc func clickEvent( _ tap : UIGestureRecognizer) {
        guard let sup = self.superview else {
            return
        }
        let translation = tap.location(in:sup )
        let windowHeight = UIApplication.rootWindow?.height
        //左上角
        if tapCorner == .leftBottom {
            if translation.x < 200 && translation.y > (windowHeight ?? 600) - 200 {
                showDebugView()
            }
        } else if tapCorner == .rightUp {
            if (translation.x > (SCREEN_WIDTH - 200)) && (translation.y < 200) {
                showDebugView()
            }
        } else {
            
        }
    }
    
    func showDebugView() {
        if self.isHidden {
            self.isHidden = false
            if let info = self.headInfoLog {
                let natt = NSMutableAttributedString(string: info,
                                                     attributes: [.foregroundColor: UIColor.black])
                natt.append(mAttributedString)

                self.debugTextView.attributedText = natt
            } else {

                self.debugTextView.attributedText = mAttributedString
            }
        }
    }
    
    private func setUI() {
        self.backgroundColor = UIColor.white
        self.addSubview(debugTextView)
        debugTextView.backgroundColor = UIColor.white
        debugTextView.isEditable = false
        debugTextView.font = UIFont.systemFont(ofSize: 15)
        debugTextView.snp.makeConstraints { (maker) in
            if #available(iOS 11.0, *) {
                maker.left.equalTo(safeAreaLayoutGuide.snp.left)
            } else {
                maker.left.equalTo(10)
            }
            maker.bottom.equalTo(10)
            maker.top.equalTo(10)
            maker.right.equalTo(0)
        }
        
        self.addButton(title: "隐藏", right: 10, action: #selector(closeDebugView))
        self.addButton(title: "刷新", right: 10+90, action: #selector(reload))
        self.addButton(title: "切换地址", right: 10+90+90, action: #selector(changeUrl))
        self.addButton(title: "清除log", right: 10+90+90+90, action: #selector(clearLog))
        self.addButton(title: "分享log", right: 10+90+90+90+90, action: #selector(openBridgeCall))
        recordLogBtn = self.addButton(title: "显示开录", right: 10+90, top: 60, action: #selector(openRecordLogCall))
        self.addButton(title: "启用离线包", right: 10+90+90, top: 60,action: #selector(didOfflineBtnCache(sender:)))
        self.addButton(title: "禁用离线包", right: 10+90+90+90, top:60,action: #selector(didOfflineBtnCache(sender:)))
        self.addButton(title: "清除离线包", right: 10+90+90+90+90, top: 60, action: #selector(didOfflineBtnCache(sender:)))
        self.addButton(title: "伙伴之家", right: 10, top: 110, action: #selector(didClickOther(sender:)))
        
    }
    
    @discardableResult
    public func addButton(title:String, right:CGFloat,top: CGFloat = 10,action: Selector) -> UIButton {
        let button = UIButton.init()
        button.setTitle(title, for: UIControl.State.normal)
        button.addTarget(self, action: action, for: UIControl.Event.touchUpInside)
        button.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        button.backgroundColor = UIColor.clear
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = actionBtnTag
        actionBtnTag+=1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            //            make.left.equalTo(left)
            make.right.equalTo(-right)
            make.width.equalTo(80)
            make.top.equalTo(top)
            make.height.equalTo(40)
        }
        return button
    }
    
    @objc func closeDebugView (){
        self.isHidden = true
        self.debugTextView.text = ""
    }
    
    func openDebugView (){
        self.isHidden = false
        //        self.debugTextView.text = ZKWLog.read
    }
    
    @objc func reload (){
        
        self.isHidden = true
        self.debugTextView.text = ""
        
        if self.clickButtonEvent != nil {
            self.clickButtonEvent?(.ReloadWeb)
        }
    }
    
    @objc func changeUrl (){
        if self.clickButtonEvent != nil {
            self.clickButtonEvent!(PTDebugViewButtonEvent.ChangeUrl(self))
        }
    }
    
    @objc func openBridgeCall(_ sender: UIButton){
        //关闭调试
        self.openShareText(text: self.debugTextView.text)
    }
    
    @objc func openRecordLogCall(_ sender: UIButton) {
        if let clickButtonEvent = self.clickButtonEvent {
            clickButtonEvent(.otherAction(5))
            if recordLogBtn?.isSelected == true {
                recordLogBtn?.setTitle("显示开录", for: .normal)
                recordLogBtn?.isSelected = false
            } else {
                recordLogBtn?.setTitle("隐藏开录", for: .normal)
                recordLogBtn?.isSelected = true
            }
            
        }
    }
    
    func openShareText(text: String) {
        let vcc = UIApplication.rootWindow?.rootViewController
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = vcc?.view
            popover.sourceRect = vcc?.view.bounds ?? .zero
            popover.permittedArrowDirections = [] // 可以设置为无箭头，使其成为全屏弹窗
        }
        vcc?.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func didClickOther(sender: UIButton) {
        if let clickButtonEvent = self.clickButtonEvent {
            clickButtonEvent(.otherAction(sender.tag))
        }
    }
    
    @objc func openAppTestVc(){
        //        let jsTestVc = RSTestViewController()
        //        homepageVc.navigationController?.pushViewController(jsTestVc, animated: true)
    }
    
    @objc func clearLog (){
        mAttributedString = NSMutableAttributedString(string: "")//日志富文本
        self.debugTextView.text = ""
        //        ZKWLog.clear()
    }
    
    @objc func didOfflineBtnCache(sender: UIButton) {
        self.clickButtonEvent?(.pkgAction(sender.tag))
        //        RSWebOfflineManager.sha
        //            URLProtocol.unregisterClass(PTURLProtocol.self)
        //            URLProtocol.wk_unregisterScheme("http")
        //            URLProtocol.wk_unregisterScheme("https")
        //            HUD.flash("禁用成功")
    }
}
