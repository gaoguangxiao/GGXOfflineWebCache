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
}

//工程
//public let ZKSCREEN_WIDTH_STATIC = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
//
//public let artScaleFactor : CGFloat = {
//    let deviceHeight = ZKSCREEN_WIDTH_STATIC
//    let designedHeight = CGFloat(UIDevice.isIPad ? 768.0 : 414.0)
//    return deviceHeight/designedHeight
//}()



open class ZKBaseView: UIView {
    
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

extension UIView {
    
    var bindModel: ZKBaseModel? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.bindModelKey) as? ZKBaseModel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.bindModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension ZKBaseView {
    
}
