//
//  ZKBaseProtocol.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/24.
//

import Foundation
import UIKit

@objc public protocol ZKNavigationViewProtocol where Self: UIViewController {
    
    func hiddenNavigationBar() -> Bool
    
    func navigationTitle() -> String?
    
    func backItemAction()
    
    @objc optional func rightItemTitle() -> String?
    
    @objc optional func rightItemClicked()
    
}

public extension ZKNavigationViewProtocol {
    
    func makeNavigationBar() {
        view.backgroundColor = .zkF7F8FA
        view.addSubview(navView)
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
            let nav = ZKNavigationView()
            nav.tag = 9999
            nav.backgroundColor = .white
            nav.isHidden = hiddenNavigationBar()
            nav.title = navigationTitle()
            nav.addBackItem { [weak self] in
                self?.backItemAction()
            }
            nav.addRightItem(name: rightItemTitle?()) { [weak self] in
                self?.rightItemClicked?()
            }
            return nav
        }
    }
}


