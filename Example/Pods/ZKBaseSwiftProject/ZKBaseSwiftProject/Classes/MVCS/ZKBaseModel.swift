//
//  ZKBaseModel.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/25.
//

import UIKit

@objcMembers
open class ZKBaseModel: NSObject {
    
    required public override init() { }

    public weak var bindView: ZKBaseView?
    
    public func bind(_ view: ZKBaseView) {
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
