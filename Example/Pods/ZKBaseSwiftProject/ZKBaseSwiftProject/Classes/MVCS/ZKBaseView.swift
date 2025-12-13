//
//  ZKBaseView.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import UIKit
import SnapKit
//代理
public protocol ZKBaseViewDelegate: NSObjectProtocol {
    func closeView()
    
    //本页重新
    func reloadNetData()
}

public extension ZKBaseViewDelegate {
    func closeView(){}
    
    //本页重新
    func reloadNetData(){}
}

open class ZKBaseView: UIView {
    
    open var bindModel: ZKBaseModel?
    
    public weak var delegatezkView : ZKBaseViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setUpView() {}
}

struct AssociatedKeys {
    static var bindModelKey: String = "ZKBindModelKey"
}

//public extension UIView {
//    
//    var bindModel: ZKBaseModel? {
//        get {
//            objc_getAssociatedObject(self, &AssociatedKeys.bindModelKey) as? ZKBaseModel
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.bindModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}
//
//extension ZKBaseView {
//    
//}
