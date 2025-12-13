//
//  UITableView+Extension.swift
//  GGXSwiftExtension
//
//  Created by 高广校 on 2025/10/13.
//

import Foundation

let defaultCellIdentifier: String = "UITableViewCell"

public extension UITableView {
    /// 便利初始化 UITableView
    static func instance(_ style: UITableView.Style = .plain) -> UITableView {
        let t = UITableView(frame: .zero, style: style)
        t.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellIdentifier)
        t.separatorStyle = .none
        t.backgroundColor = UIColor.clear
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 200 // 太小会跳动、太大会算不准、可以在具体的页面具体上下调整
        t.estimatedSectionHeaderHeight = 0
        t.estimatedSectionFooterHeight = 0
        if #available(iOS 11, *) {
            t.contentInsetAdjustmentBehavior = .never
        }
        if style == .grouped {
            t.sectionHeaderHeight = .leastNormalMagnitude
            t.sectionFooterHeight = .leastNormalMagnitude
        }
        return t
    }
    
    /// 自定义注册cell
    func registerCell(_ class: UITableViewCell.Type) {
        register(`class`, forCellReuseIdentifier: NSStringFromClass(`class`))
    }
    /// 自定义获取重用cell
    func dequeueReusableCell(_ cell: UITableViewCell.Type, for indexPath: IndexPath) -> UITableViewCell {
        dequeueReusableCell(withIdentifier: NSStringFromClass(cell), for: indexPath)
    }
    
    // MARK: - UITabelView的section头部不置顶
    /// 「section头部」不置顶的方法
    func setSectionHeaderNotTop(sectionH: CGFloat) {
        if self.contentOffset.y <= sectionH && self.contentOffset.y >= 0 {
            if self.contentInset.top != -self.contentOffset.y {
                self.contentInset = UIEdgeInsets.init(top: -self.contentOffset.y, left: 0, bottom: 0, right: 0)
            }
        } else if self.contentOffset.y >= sectionH {
            if self.contentInset.top != -sectionH {
                self.contentInset = UIEdgeInsets.init(top: -sectionH, left: 0, bottom: 0, right: 0)
            }
        }
    }
}
