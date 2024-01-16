//
//  ZKBaseViewController.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import UIKit

open class ZKBaseViewController: UIViewController  {
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

