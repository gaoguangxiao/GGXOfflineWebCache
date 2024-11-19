//
//  CGButtonCheckBox.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/9.
//  Copyright © 2017年 高广校. All rights reserved.
//

import UIKit

public class ZKButtonCheckBox: ZKButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func Init()  {
        self.addTarget(self, action: #selector(clicked), for: UIControl.Event.touchUpInside)
    }
 
    @objc func clicked() -> Void {
        self.isSelected = !self.isSelected
    }
}
