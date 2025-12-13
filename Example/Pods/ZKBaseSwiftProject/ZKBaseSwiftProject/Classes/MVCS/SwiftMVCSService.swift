//
//  SwiftMVCSService.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/11/12.
//

import UIKit

open class SwiftMVCSService<SwiftViewModel: ZKBaseModel>: ZKBaseService {

    public weak var controller: UIViewController?
    
    public weak var viewModel: SwiftViewModel?
    
}
