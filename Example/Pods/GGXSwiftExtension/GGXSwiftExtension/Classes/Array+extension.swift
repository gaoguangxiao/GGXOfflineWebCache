//
//  Array+extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/9.
//  Copyright © 2017年 高广校. All rights reserved.
//

import Foundation

extension Array{
    
    func removeObject(object: String) -> Array<String>{

        var temp = self as!Array<String>
        if let removeIndex = temp.index(where: {$0 == object}) {
            temp.remove(at:removeIndex)
        }
        return temp
    }

}
