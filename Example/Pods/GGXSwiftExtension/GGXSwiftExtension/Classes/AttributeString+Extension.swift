//
//  AttributeString+CommonExtension.swift
//  DDKit
//
//  Created by FreakyYang on 2018/5/8.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import Foundation
import UIKit

public extension NSMutableAttributedString {
    func replacingOccurrences(of stringToReplace: String, with newStringPart: String) -> NSMutableAttributedString {
        guard let mutableAttributedString = mutableCopy() as? NSMutableAttributedString else {
            return self
        }
        let mutableString = mutableAttributedString.mutableString

        while mutableString.contains(stringToReplace) {
            let rangeOfStringToBeReplaced = mutableString.range(of: stringToReplace)
            mutableAttributedString.replaceCharacters(in: rangeOfStringToBeReplaced, with: newStringPart)
        }
        return mutableAttributedString
    }
    
    // MARK: 修改字体颜色
    func dosageStringColor(_ allText: String, length: NSInteger, atIndex: NSInteger, color: UIColor)->NSMutableAttributedString{
        let dosageStr: NSMutableAttributedString = NSMutableAttributedString(string: allText)
        dosageStr.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(atIndex, length))
        return dosageStr
    }
    
    // MARK: 修改字体大小
    func dosageStringFont(_ allText: NSMutableAttributedString, length: NSInteger, atIndex: NSInteger, font: UIFont)->NSMutableAttributedString{
        let dosageStr: NSMutableAttributedString = NSMutableAttributedString(attributedString: allText)
        dosageStr.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(atIndex, length))
        return dosageStr
    }
    
    // MARK: 修改文字行间距
    func changeLianeSpacing(_ attributedString: NSMutableAttributedString) -> NSMutableAttributedString{
        var changedAttributedString: NSMutableAttributedString!
        if attributedString.length > 0 {
            changedAttributedString = NSMutableAttributedString(attributedString: attributedString)
            let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            changedAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        }
        return changedAttributedString
    }
}
