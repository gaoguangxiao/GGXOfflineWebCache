//
//  ZKInputView.swift
//  paipai
//
//  Created by 高广校 on 2023/11/13.
//  Copyright © 2023 瑞思. All rights reserved.
//

import Foundation
//import ZKBaseSwiftProject
import UIKit

@dynamicMemberLookup
public class ZKInputView : ZKBaseView {
    
    public override func setUpView() {
     
        self => backgroundView
        self => leftImageView
        self => centerTextField
        self => rightBtn
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        leftImageView.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerY.equalToSuperview()
        }

        centerTextField.snp.makeConstraints { make in
            make.left.equalTo(leftImageView.snp.right).offset(50)
            make.top.bottom.equalTo(0)
            make.right.equalTo(rightBtn.snp.left)
        }
        //第一方案-实现输入框 清理按钮 右边距可调
//        centerTextField.rightView = rightView
//        centerTextField.rightViewMode = .always
//        //添加右边按钮
//        rightView => rightBtn
//        rightBtn.snp.makeConstraints { make in
//            make.right.equalTo(-20)
//            make.top.equalTo(0)
//            make.left.equalTo(0)
//            make.bottom.equalTo(0)
//        }
        
        //第二方案，自定义按钮，清理按钮不可见
        self => rightBtn
        rightBtn.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.top.equalTo(0)
            make.width.equalTo(50)
            make.bottom.equalTo(0)
        }
    }
    
    //对输入框操作
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<UITextField, T>) -> T {
        get { centerTextField[keyPath: keyPath] }
        set { centerTextField[keyPath: keyPath] = newValue }
    }
    
    public lazy var backgroundView = UIView().zkBackgroundColor(UIColor.white).zkLayerCornerRadius(30).zkAlpha(0.5)
    
    public lazy var leftView = ZKView(UIView()).view
    public lazy var leftImageView = ZKView(UIImageView()).contentMode(.scaleAspectFit).view
 
    public lazy var centerTextField: UITextField = {
        let textField = ZKView(UITextField()).textColor(.zk333333).font(.regular(21)).textAlignment(.left).view
        return textField
    }()
    
    //因为UITextField的rightView中frame无法改变，只能用UIView修改
    public lazy var rightView = ZKView(UIView()).view
    
    public lazy var rightBtn: UIButton = {
        let btn = ZKView(UIButton(type: .custom)).view
        return btn
    }()
}
