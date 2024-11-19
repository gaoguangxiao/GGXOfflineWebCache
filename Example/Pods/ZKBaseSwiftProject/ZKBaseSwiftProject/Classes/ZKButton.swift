//
//  ZKButton.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/9.
//  Copyright © 2017年 高广校. All rights reserved.
//

import UIKit

open class ZKButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        Init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        Init()
    }
    
    func Init()  {
        
    }
}
