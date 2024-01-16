//
//  SwiftMVCSService.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/11/12.
//

import UIKit

class SwiftMVCSService<SwiftViewModel: ZKBaseModel>: ZKBaseService {

    weak var controller: UIViewController?
    
    weak var viewModel: SwiftViewModel?
    
}
