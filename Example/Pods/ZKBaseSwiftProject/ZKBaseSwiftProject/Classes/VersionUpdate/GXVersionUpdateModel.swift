//
//  GXVersionUpdateModel.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2024/1/29.
//

import Foundation

public class GXVersionUpdateModel: ZKJSONModel {
    
    public var downloadUrl: String?
    public var latest: String?
    public var min: String?
    public var phVersion: String?
    public var releaseNote: String?
    public var title: String?
    
}
