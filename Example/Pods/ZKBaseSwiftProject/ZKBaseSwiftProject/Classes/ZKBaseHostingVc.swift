//
//  ZKBaseHostingVc.swift
//  ZKNASProj
//
//  Created by gaoguangxiao on 2022/11/2.
//

import SwiftUI
import GGXSwiftExtension

@available(iOS 13.0, *)
open class ZKBaseHostingVc<Content>: UIHostingController<Content> where Content: View {
   
    var _rootView: Content?
    
    public lazy var backBtn = UIButton(type: .custom).zkNormalImgName("loginBackA").zkAction(self, action: #selector(backBtnClick))
    
//    var rootVc: UIViewController?
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    /// 初始化控制器
    /// - Parameters:
    ///   - rootView:SwiftUI
    ///   - superVc: 父类控制器
    @discardableResult
    public init(rootView: Content,superVc:UIViewController) {
        super.init(rootView: rootView)
        superVc.addChild(self)
        superVc.view.addSubview(self.view)
    }
    
    /// 初始化控制器
    /// - Parameters:
    ///   - rootView:SwiftUI
    ///   - superVc: 父类控制器
    @discardableResult
    public override init(rootView: Content) {
        super.init(rootView: rootView)
        
//        self.rootView
        makeNavigationBar()
    }
    
    @MainActor required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 返回
    func makeNavigationBar() {
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            if UIDevice.isIPad {
                make.top.equalTo(self.view).offset(StatusBarHeight + 30)
            } else {
                make.top.equalTo(self.view).offset(24 * ZKAdapt.factor)
            }
            make.left.equalTo(self.view).offset(StatusBarHeight)
            make.size.equalTo(CGSize(width: 50.0 * ZKAdapt.factor, height:50.0 * ZKAdapt.factor))
        }
    }
    
    @objc open func backBtnClick() {
        pop()
    }
}

@available(iOS 13.0, *)
public extension ZKBaseHostingVc {
 
}


@available(iOS 13.0, *)
extension ZKBaseHostingVc {
    
//    open func navigationTitle() -> String? {
//        return nil
//    }
//    
//    open func hiddenNavigationBar() -> Bool {
//        return false
//    }
//    
//    open func backItemAction() {
//        self.navigationController?.popViewController(animated: true)
//    }
    
}
