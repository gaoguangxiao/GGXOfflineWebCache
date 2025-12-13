//
//  ZKBaseTableViewCell.swift
//  ZKNASProj
//
//  Created by gaoguangxiao on 2022/11/15.
//

import UIKit

open class ZKBaseTableViewCell: UITableViewCell {

    var indexPath : IndexPath = IndexPath(row: 0, section: 0)
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()

//        contentView => lineView
//        lineView.snp.makeConstraints { make in
//            make.bottom.equalTo(-0.5)
//            make.left.equalTo(15)
//            make.right.equalTo(-15)
//            make.height.equalTo(0.5)
//        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setUpView() {}
    
    @objc func tapGesture() {
        //待实现 ZKBaseModel中的 zkSelector
//        if yb?.responds(to: <#T##Selector!#>)
    }
    
//    lazy var lineView = UIView()
}
