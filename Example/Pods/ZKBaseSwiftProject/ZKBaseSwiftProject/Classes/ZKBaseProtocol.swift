//
//  ZKBaseProtocol.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/24.
//

import Foundation
import UIKit
import GGXSwiftExtension

@objc public protocol ZKNavigationViewProtocol where Self: UIViewController{
    
    func hiddenNavigationBar() -> Bool
    
    func navigationTitle() -> String?
    
    func navigationHeight() -> CGFloat
    
    func backItemImageName() -> String?
    
    func backItemAction()
    
    @objc optional func rightItemTitle() -> String?
    
    @objc optional func rightItemClicked()
    
}

public extension ZKNavigationViewProtocol {
    
    func makeNavigationBar() -> ZKNavigationView {
        view.backgroundColor = .zkF7F8FA
        let na = navView
        view.addSubview(na)
        return na
    }
    
    func hiddenNavigationBar(_ isHidden: Bool) {
        if isHidden {
            let nav = view.viewWithTag(9999)
            nav?.removeFromSuperview()
        } else {
            view.addSubview(navView)
        }
    }
    
     var navView: ZKNavigationView {
        get {
            let nav = ZKNavigationView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: navigationHeight()))
            nav.tag = 9999
            nav.backgroundColor = .white
            nav.isHidden = hiddenNavigationBar()
            nav.title = navigationTitle()
            if let backImageName = backItemImageName() {
                nav.addBackItem(imageName: backImageName) { [weak self] in
                    guard let self else { return }
                    backItemAction()
                }
            } else {
                nav.addBackItem { [weak self] in
                    guard let self else { return }
                    backItemAction()
                }
            }
            nav.addRightItem(name: rightItemTitle?()) { [weak self] in
                self?.rightItemClicked?()
            }
            return nav
        }
    }
    
    func updateSenderBackImage(imageName: String) {
        navView.backBtn.zkNormalHigTDImg(imageName)
    }
}


