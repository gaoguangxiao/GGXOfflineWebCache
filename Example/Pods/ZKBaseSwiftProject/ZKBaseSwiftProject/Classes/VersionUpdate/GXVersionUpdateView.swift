//
//  GXVersionUpdateView.swift
//  KidReading
//
//  Created by zoe on 2019/8/12.
//  Copyright © 2019 putao. All rights reserved.
//

import Foundation
import GGXSwiftExtension

public class GXVersionUpdateView: UIView {
    
    private let backgroundView = UIView.init()
    
    private let borderView = UIView.init()
    
    private let titleLabel = UILabel.init()
    
    private let tipTextView = UITextView.init()
    
    private let cancelButton = UIButton.init()

    private let updateButton = UIButton.init()

    private var updateButtonEvent :((Bool)-> Void )? = nil
    
    private let rate : CGFloat = {
        let deviceHeight = SCREEN_HEIGHT
        let designedHeight = CGFloat.init(UIDevice.isIPad ? 768.0 : 414.0)
        return deviceHeight/designedHeight
    }()
    
    private var forceUpdate = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        
        self.backgroundColor = UIColor.clear
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.6

        self.borderView.backgroundColor = UIColor.white
        self.borderView.layer.masksToBounds = true
        self.borderView.layer.cornerRadius = 30
        
        self.titleLabel.text = ""
        self.titleLabel.font = UIFont.systemFont(ofSize: UIDevice.isIPad ? 22*rate : 20*rate)
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = .white
        self.titleLabel.backgroundColor = UIColor.init(hex: "FFD661")

        self.tipTextView.isEditable = false
        self.tipTextView.backgroundColor = UIColor.white
        
        self.cancelButton.setTitle("暂不升级", for: UIControl.State.normal)
        self.cancelButton.setTitleColor(UIColor.init(hex: "333333"), for: UIControl.State.normal)
        self.cancelButton.backgroundColor = UIColor.init(hex: "F0F0F0")
        self.cancelButton.addTarget(self, action: #selector(cancelButtonBeClick), for: UIControl.Event.touchUpInside)
        self.cancelButton.layer.cornerRadius = UIDevice.isIPad ? 27.5*rate : 22.5*rate
        self.cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: UIDevice.isIPad ? 18*rate : 16*rate)
        
        self.updateButton.setTitle("现在升级", for: UIControl.State.normal)
        self.updateButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
//        self.updateButton.layer.masksToBounds = true
        self.updateButton.backgroundColor = UIColor.init(hex: "FFD55F")
        self.updateButton.addTarget(self, action: #selector(updateButtonBeClick), for: UIControl.Event.touchUpInside)
        self.updateButton.layer.cornerRadius = UIDevice.isIPad ? 27.5*rate : 22.5*rate
        self.updateButton.titleLabel?.font = UIFont.systemFont(ofSize: UIDevice.isIPad ? 18*rate : 16*rate)
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.borderView)
        self.borderView.addSubview(self.titleLabel)
        self.borderView.addSubview(self.tipTextView)
        self.borderView.addSubview(self.cancelButton)
        self.borderView.addSubview(self.updateButton)
        
    }
    
    public override func layoutSubviews() {
        
        self.backgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
                
        self.borderView.snp.makeConstraints { (maker) in
            maker.width.equalTo(UIDevice.isIPad ? 570 * rate : 486 * rate)
            maker.height.equalTo(UIDevice.isIPad ? 386 * rate : 280 * rate)
            maker.center.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.width.equalToSuperview()
            maker.top.equalTo(0)
            maker.height.equalTo(UIDevice.isIPad ? 76*rate : 60*rate)
        }
        
        self.tipTextView.snp.makeConstraints { (maker) in
            maker.left.equalTo(UIDevice.isIPad ? 50*rate : 39*rate)
            maker.right.equalTo(UIDevice.isIPad ? -50*rate : -39*rate)
            maker.top.equalTo(self.titleLabel.snp.bottom).offset(UIDevice.isIPad ? 18*rate : 16*rate)
            maker.bottom.equalTo(self.updateButton.snp.top).offset(UIDevice.isIPad ? -11*rate : -14*rate)
        }
        
        if forceUpdate == true {
            self.cancelButton.isHidden = true
            
            self.updateButton.snp.makeConstraints { (maker) in
                maker.width.equalTo(UIDevice.isIPad ? 190*rate : 130*rate)
                maker.centerX.equalToSuperview()
                maker.bottom.equalTo(UIDevice.isIPad ? -20*rate : -20*rate)
                maker.height.equalTo(UIDevice.isIPad ? 55*rate : 45*rate)
            }

        } else {
            self.cancelButton.isHidden = false

            self.cancelButton.snp.makeConstraints { (maker) in
                maker.width.equalTo(UIDevice.isIPad ? 190*rate : 130*rate)
                maker.left.equalTo(UIDevice.isIPad ? 63*rate : 73*rate)
                maker.bottom.equalTo(UIDevice.isIPad ? -20*rate : -20*rate)
                maker.height.equalTo(UIDevice.isIPad ? 55*rate : 45*rate)

            }
            self.updateButton.snp.makeConstraints { (maker) in
                maker.width.equalTo(UIDevice.isIPad ? 190*rate : 130*rate)
                maker.right.equalTo(UIDevice.isIPad ? -63*rate : -73*rate)
                maker.bottom.equalTo(UIDevice.isIPad ? -20*rate : -20*rate)
                maker.height.equalTo(UIDevice.isIPad ? 55*rate : 45*rate)
            }

        }
        
    }
    
    private func setUpdateInfo(_ info : String) {
        
        let attrStr = NSMutableAttributedString(string: info)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = UIDevice.isIPad ? 10*rate : 10*rate
        attrStr.addAttributes([NSAttributedString.Key.paragraphStyle:style,
                               NSAttributedString.Key.font:UIFont.systemFont(ofSize: UIDevice.isIPad ? 16 * rate: 14 * rate),
                               NSAttributedString.Key.foregroundColor:UIColor.init(hex: "666666")
            ], range: NSMakeRange(0, attrStr.length))
        self.tipTextView.attributedText = attrStr
//        self.tipTextView.text = info
    }
    
    func showVersionUpdateView(vc: UIViewController, title: String, info: String, forceUpdate: Bool, updateEvent: @escaping (Bool)->Void)  {
       
        /*if let vc = UIApplication.shared.keyWindow?.rootViewController {
            UserDefaults.VersionUpdate.set(value: "true", forKey: .isUpdate)//标记弹出升级框
            self.setUpdateInfo(info)
            self.forceUpdate = forceUpdate
            self.updateButtonEvent = updateEvent
            self.titleLabel.text = title
            
            vc.view.addSubview(self)
            self.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } else {
            delay(time: 2, task: {
                self.showVersionUpdateView(title :title,info: info, forceUpdate: forceUpdate, updateEvent: updateEvent)
            })
        }*/
        
//        UserDefaults.VersionUpdate.set(value: "true", forKey: .isUpdate)标记弹出升级框
//        self.setUpdateInfo("1提升服务稳定性\n2提升服务稳定性\n3提升服务稳定性\n4提升服务稳定性")
        self.setUpdateInfo(info)
        self.forceUpdate = forceUpdate
        self.updateButtonEvent = updateEvent
        self.titleLabel.text = title
        
        if let rootView = UIApplication.rootWindow {
//            rootView.view.addSubview(self)
            rootView.addSubview(self)
            self.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
        }
        
        self.setNeedsLayout()
    }
    
    @objc func cancelButtonBeClick() {
       
        if self.updateButtonEvent != nil {
            self.updateButtonEvent?(false)
        }
        self.removeFromSuperview()
        self.updateButtonEvent = nil
    }
    
    @objc func updateButtonBeClick() {
        if self.updateButtonEvent != nil {
            self.updateButtonEvent?(true)
        }
        
    }
    
}

