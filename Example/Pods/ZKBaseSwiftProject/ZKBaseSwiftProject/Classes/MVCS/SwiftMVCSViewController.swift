//
//  SwiftMVCSViewController.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/11/12.
//

import UIKit


class SwiftMVCSViewController<SwiftView: ZKBaseView, SwiftViewModel: ZKBaseModel, SwiftService: ZKBaseService> : ZKBaseViewController  {

    lazy var rootView: SwiftView = {
        let view = SwiftView()
        (view as? SwiftMVCSView)?.eventDelegate = self
        return view
    }()
    
    let viewModel = SwiftViewModel()
    
    lazy var service: SwiftService = {
        let service = SwiftService()
        (service as? SwiftMVCSService)?.controller = self
        (service as? SwiftMVCSService)?.viewModel = viewModel
        return service
    }()
    
    override func loadView() {
        view = rootView
        viewModel.bind(rootView)
    }
    
}
