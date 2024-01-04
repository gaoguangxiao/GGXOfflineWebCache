//
//  UIKit+Extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/8.
//  Copyright © 2017年 高广校. All rights reserved.
//

import UIKit

extension UIView {
    static func createSectionView() -> UIView {
        return Bundle.main.loadNibNamed(self.identifierView, owner: self, options: nil)?[0] as! UIView
    }

    static var identifierView: String {
        get{
            return NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!
        }
    }
}
