//
//  ZKBaseTableViewCell.swift
//  ZKNASProj
//
//  Created by gaoguangxiao on 2022/11/15.
//

import UIKit

class ZKBaseTableViewCell: UITableViewCell {

    var indexPath : IndexPath = IndexPath(row: 0, section: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture))
//        contentView.addGestureRecognizer(tap)
        
        contentView => lineView
        lineView.snp.makeConstraints { make in
            make.bottom.equalTo(-0.5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapGesture() {
        //待实现 ZKBaseModel中的 zkSelector
//        if yb?.responds(to: <#T##Selector!#>)
    }
    
    lazy var lineView = UIView()
}
