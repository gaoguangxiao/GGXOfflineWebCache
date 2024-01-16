//
//  SwiftView.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/11/12.
//

import UIKit


class SwiftMVCSView<SwiftViewModel: ZKBaseModel>: ZKBaseView {
    
    weak var eventDelegate: AnyObject?
    
    weak var viewModel: SwiftViewModel? {
        bindModel as? SwiftViewModel
    }
}
