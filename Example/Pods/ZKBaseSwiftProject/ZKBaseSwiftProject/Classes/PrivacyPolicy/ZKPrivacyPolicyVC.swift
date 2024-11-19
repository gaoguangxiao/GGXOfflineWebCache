//
//  ZKPrivacyPolicyVC.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2023/12/27.
//

import Foundation

open class ZKPrivacyPolicyVC: ZKBaseViewController {
    
    public var isAgree: ((Bool)->(Void))!// 同意成功回调
    
    public var info: String?
    //用户协议地址
    public var uesrProtolUrl: String?
    //隐私政策地址
    public var privacyUrl: String?
    //儿童隐私保护地址
    public var childInfoUrl: String?
    
    public var themeColor: UIColor?
    
    open override func hiddenNavigationBar() -> Bool {
        return true
    }
    
    /// device support orientation
    public var supportOrientationMask: UIInterfaceOrientationMask?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // 设置屏幕方向
        ZKUtils.supportOrientationMask = supportOrientationMask
        
        let alertView = ZKPrivacyPolicyView.init(frame: CGRect.zero)
        alertView.tag = 100
        if let themeColor {
            alertView.themeColor = themeColor
        }
        guard let info = info else {
            print("info 内容不得为空")
            return
        }
        
        let attrStr = NSMutableAttributedString(string: info)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10 * ZKAdapt.rate
        attrStr.addAttributes([NSAttributedString.Key.paragraphStyle:style,
                               NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16 * ZKAdapt.rate),
                               NSAttributedString.Key.foregroundColor:UIColor.init(hex: "0C0C0C")
            ], range: NSMakeRange(0, attrStr.length))
        let userRange: NSRange = self.getStringRange(info: info, str: "《用户协议》")
        attrStr.addAttribute(NSAttributedString.Key.link, value: "uesrProtorl://", range: userRange)
        let privacyRange: NSRange = self.getStringRange(info: info, str: "《隐私政策》")
        attrStr.addAttribute(NSAttributedString.Key.link, value: "privacy://", range: privacyRange)
        let childInfoRange: NSRange = self.getStringRange(info: info, str: "《儿童个人信息保护规则及监护人须知》")
        attrStr.addAttribute(NSAttributedString.Key.link, value: "childInfo://", range: childInfoRange)
        
        alertView.showVersionUpdateView(vc: self, title: "温馨提示", info: attrStr) { isAgree in
            if isAgree {
                UserDefaults.agreePrivacyPolicy = true
                self.isAgree(true)
            }
        } openUrlEvent: { str in
            let delegateVc = ZKBaseWKWebViewController.init()
            if str == "uesrProtorl" {//用户协议
                if let uesrProtolUrl = self.uesrProtolUrl {
                    delegateVc.urlString = uesrProtolUrl
                }
            } else if str == "privacy" {//隐私政策
                if let privacyUrl = self.privacyUrl {
                    delegateVc.urlString = privacyUrl
                }
            } else if str == "childInfo" {//儿童信息
                if let childInfoUrl = self.childInfoUrl {
                    delegateVc.urlString = childInfoUrl
                }
            }
            self.navigationController?.pushViewController(delegateVc, animated: true)
        }    
    }
    
    func getStringRange(info: String, str: String) -> NSRange {
        let range: Range = info.range(of: str)!
        let location = info.distance(from: info.startIndex, to: range.lowerBound)
        return NSRange(location: location, length: str.count)
    }
    
}
