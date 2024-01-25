//
//  ZKBaseViewController.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import UIKit
import RxSwift

open class ZKBaseViewController: UIViewController  {
    
    public var disposeBag = DisposeBag()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationBar()
    }
}


extension ZKBaseViewController: ZKNavigationViewProtocol {
    
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
