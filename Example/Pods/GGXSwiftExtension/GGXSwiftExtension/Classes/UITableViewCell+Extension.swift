//
//  UITableViewCell+Extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/7.
//  Copyright © 2017年 高广校. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell{
    static func nib() -> UINib {
        return UINib.init(nibName: self.identifier, bundle: nil)
    }
    
    static func createCell() -> UITableViewCell {
        return Bundle.main.loadNibNamed(self.identifier, owner: self, options: nil)?[0] as! UITableViewCell
    }
    
    static var identifier: String {
        get{
            return NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!
        }
    }

}
