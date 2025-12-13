//
//  ZKBaseViewController.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import UIKit
import RxSwift
import GGXSwiftExtension

open class ZKBaseViewController: UIViewController  {
    
    public var disposeBag = DisposeBag()
    
    /// 进入之前的屏幕方向
    public var isBeferOrientationMask: UIInterfaceOrientationMask = .landscape
    
    //顶部导航栏
    public var topNavView: ZKNavigationView?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        topNavView = makeNavigationBar()
        
        topNavView?.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(navigationHeight())
        }

    }
}


extension ZKBaseViewController: ZKNavigationViewProtocol {
    
    open func navigationHeight() -> CGFloat {
        return TopBarHeight
    }
    
    open func backItemImageName() -> String? {
        return nil
    }
    
    open func navigationTitle() -> String? {
        return nil
    }
    
    open func hiddenNavigationBar() -> Bool {
        return false
    }
    
    open func backItemAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ZKBaseViewController {
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
