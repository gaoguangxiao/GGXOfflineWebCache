//
//  ZKPrivacyPolicyView.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2023/12/27.
//

import UIKit
import GGXSwiftExtension

public class ZKPrivacyPolicyView: UIView {

    private let backgroundView = UIView.init()
    
    public let borderView = UIView.init()
    
    private let titleLabel = UILabel.init()
    
    private let tipTextView = UITextView.init()
    
    private let agreeButton = UIButton.init()

    private let disagreeButton = UIButton.init()

    private var agreeBoolEvent :ZKBoolClosure?
    
    private var disAgreeBoolEvent :ZKBoolClosure?

    /// 是否需要再次弹框，默认true，会关闭app.true会有回调false
    public var isNeedAgainAlert = true

    /// 是否允许蒙版点击
    public var isAllowMaskClick = false
    
    /// 打开URL事件
    private var openUrlEvent: ZKStringClosure?
    
//    public var themeColor: UIColor = UIColor.hex(0xA5673C)
    
    public var themeColor: UIColor {
        get {
            return self.titleLabel.textColor
        }
        set {
            self.titleLabel.backgroundColor = newValue
            self.agreeButton.backgroundColor = newValue
        }
    }
    private let rate : CGFloat = {
        let deviceHeight = SCREEN_HEIGHT
        let designedHeight = CGFloat.init(UIDevice.isIPad ? 768.0 : 414.0)
        return deviceHeight/designedHeight
    }()
    
    private var forceUpdate = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    private func setUI() {
        self.backgroundColor = UIColor.clear
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.6

        let backTap = UITapGestureRecognizer(target: self, action: #selector(disTapBeClick))
        self.backgroundView.addGestureRecognizer(backTap)
        
        self.borderView.backgroundColor = UIColor.white
        self.borderView.layer.masksToBounds = true
        self.borderView.layer.cornerRadius = 29*rate
        
        self.titleLabel.text = ""
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: UIDevice.isIPad ? 22*rate : 20*rate)
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = UIColor(hex: "A5673C")
        self.titleLabel.backgroundColor = UIColor.init(hex: "FFD661")

        self.tipTextView.isEditable = false
        self.tipTextView.backgroundColor = UIColor.white
        self.tipTextView.delegate = self
        
        
        self.agreeButton.setTitle("同意", for: UIControl.State.normal)
        self.agreeButton.setTitleColor(UIColor(hex: "A5673C"), for: UIControl.State.normal)
        self.agreeButton.layer.masksToBounds = true
        self.agreeButton.backgroundColor = UIColor.init(hex: "FFD55F")
        self.agreeButton.addTarget(self, action: #selector(agreeButtonBeClick), for: UIControl.Event.touchUpInside)
        let iphoneCorner = 45*rate/2
        let iPadCorner = 55*rate/2
        self.agreeButton.layer.cornerRadius = UIDevice.isIPad ? iPadCorner : iphoneCorner
        self.agreeButton.titleLabel?.font = UIFont.systemFont(ofSize: UIDevice.isIPad ? 18*rate : 16*rate)
        
        self.disagreeButton.setTitle("不同意", for: UIControl.State.normal)
        self.disagreeButton.backgroundColor = UIColor.init(hex: "F0F0F0")
        self.disagreeButton.setTitleColor(UIColor.init(hex: "333333"), for: UIControl.State.normal)
        self.disagreeButton.addTarget(self, action: #selector(disagreeButtonBeClick(sender:)), for: UIControl.Event.touchUpInside)
        self.disagreeButton.tag = 1
        self.disagreeButton.layer.cornerRadius = UIDevice.isIPad ? iPadCorner : iphoneCorner
        self.disagreeButton.titleLabel?.font = UIFont.systemFont(ofSize: UIDevice.isIPad ? 18*rate : 16*rate)
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.borderView)
        self.borderView.addSubview(self.titleLabel)
        self.borderView.addSubview(self.tipTextView)
        self.borderView.addSubview(self.agreeButton)
        self.borderView.addSubview(self.disagreeButton)
        
        self.backgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
                
        self.borderView.snp.makeConstraints { (make) in
            make.width.equalTo(UIDevice.isIPad ? 570.0 * rate : 486.0 * rate)
            make.height.equalTo(UIDevice.isIPad ? 386.0 * rate : 280.0 * rate)
            make.center.equalToSuperview()
        }
    }
    
    
    public override func layoutSubviews() {
                
        self.titleLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.width.equalToSuperview()
            maker.top.equalTo(0)
            maker.height.equalTo(UIDevice.isIPad ? 76*rate : 60*rate)
        }
        
        self.tipTextView.snp.makeConstraints { (maker) in
            maker.left.equalTo(UIDevice.isIPad ? 50 * rate : 39 * rate)
            maker.right.equalTo(UIDevice.isIPad ? -50 * rate : -39 * rate)
            maker.top.equalTo(self.titleLabel.snp.bottom).offset(UIDevice.isIPad ? 18 * rate : 16 * rate)
            maker.bottom.equalTo(self.agreeButton.snp.top).offset(UIDevice.isIPad ? -11 * rate : -14 * rate)
        }
        
        self.agreeButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.tipTextView.snp.bottom).offset(UIDevice.isIPad ? 11 * rate : 14 * rate)
            maker.right.equalTo(UIDevice.isIPad ? -63 * rate : -78 * rate)
            maker.bottom.equalTo(UIDevice.isIPad ? -20 * rate : -20 * rate)
            maker.height.equalTo(UIDevice.isIPad ? 55*rate : 45*rate)
            maker.width.equalTo(UIDevice.isIPad ? 190*rate : 130*rate)
        }
        
        self.disagreeButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.tipTextView.snp.bottom).offset(UIDevice.isIPad ? 11 * rate : 14 * rate)
            maker.left.equalTo(UIDevice.isIPad ? 63 * rate : 78 * rate)
            maker.bottom.equalTo(UIDevice.isIPad ? -20 * rate : -20 * rate)
            maker.height.equalTo(UIDevice.isIPad ? 55*rate : 45*rate)
            maker.width.equalTo(UIDevice.isIPad ? 190*rate : 130*rate)

        }
    }
    
    public func disagreeButtonTitle(title: String) {
        self.disagreeButton.setTitle(title, for: .normal)
//        print("设置取消")
    }
    
    public func showVersionUpdateView(vc: UIViewController? = nil,
                               title: String,
                               info: NSAttributedString,
                               agreeEvent: @escaping ZKBoolClosure,
                               openUrlEvent: @escaping ZKStringClosure
    )  {
        
        self.tipTextView.attributedText = info
        self.agreeBoolEvent = agreeEvent
        self.openUrlEvent   = openUrlEvent
        self.titleLabel.text = title

        if let vc {
            vc.view.addSubview(self)
        } else {
            if let windowRootVc = UIApplication.rootWindow?.rootViewController {
                windowRootVc.view.addSubview(self)
            }
        }
        self.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    

    @objc func disTapBeClick() {
        guard isAllowMaskClick else { return  }
        self.removeFromSuperview()
        agreeBoolEvent?(false)
    }
    
    //MARK button event
    @objc func agreeButtonBeClick() {
        self.removeFromSuperview()
        agreeBoolEvent?(true)
    }
    
    @objc func disagreeButtonBeClick(sender: UIButton) {
        
        guard isNeedAgainAlert else {
            self.removeFromSuperview()
            agreeBoolEvent?(false)
            return
        }
        
        if sender.tag == 2 {
             exit(0)
        }
        self.borderView.snp.remakeConstraints { (maker) in
            maker.top.equalTo(self).offset(SCREEN_HEIGHT)
            maker.width.equalTo(UIDevice.isIPad ? 570 * rate : 486 * rate)
            maker.height.equalTo(UIDevice.isIPad ? 386 * rate : 280 * rate)
            maker.center.equalToSuperview()
        }
        self.needsUpdateConstraints()
        // 调用此方法告诉self.view检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
        self.updateConstraintsIfNeeded()
//        
        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
        }) { (complete) in

            self.borderView.snp.remakeConstraints { (maker) in
                maker.width.equalTo(UIDevice.isIPad ? 570 * self.rate : 486 * self.rate)
                maker.height.equalTo(UIDevice.isIPad ? 386 * self.rate : 280 * self.rate)
                maker.center.equalToSuperview()
            }
            self.needsUpdateConstraints()
            // 调用此方法告诉self.view检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
            self.updateConstraintsIfNeeded()
            UIView.animate(withDuration: 0.4, animations: {
                self.layoutIfNeeded()
            }) { (complete) in
                self.titleLabel.text = "再次温馨提示"
                self.disagreeButton.setTitle("不同意并退出", for: UIControl.State.normal)
                self.disagreeButton.tag = 2
            }
        }
    }
}

extension ZKPrivacyPolicyView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
         guard let urlScheme = URL.scheme else {
             return true
         }
         if let openUrlEvent = openUrlEvent {
             openUrlEvent(urlScheme)
         }
        return true
        
    }
}
