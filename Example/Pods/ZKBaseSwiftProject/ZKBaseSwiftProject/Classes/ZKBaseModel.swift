//
//  ZKBaseModel.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/25.
//

import UIKit

@objcMembers
open class ZKBaseModel: NSObject{
    
    required public override init() { }

    weak var bindView: UIView?
    
    func bind(_ view: UIView) {
        if bindView != nil {
            bindView = nil
        }
        bindView = view
        
        if bindView?.bindModel != nil {
            bindView?.bindModel = nil
        }
        view.bindModel = self
    }
    
//    public func mapping(mapper: HelpingMapper) {
//        mapper.specify(property: &id, name: "ID")
//    }
//    public override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
//        return ["ID":"id","des":"description"]
//    }
}
