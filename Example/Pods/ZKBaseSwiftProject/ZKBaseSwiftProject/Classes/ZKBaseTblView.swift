//
//  ZKBaseTblView.swift
//  ZKNASProj
//
//  Created by gaoguangxiao on 2022/11/23.
//

import UIKit

open class ZKBaseTblView: ZKBaseView {

    public var dataArray: [Any] = []
    
    public var tableView: UITableView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    
        self => tbl
             
        tbl.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView = tbl
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var tbl: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.rowHeight = 40
//        view.estimatedRowHeight = UITableView.automaticDimension
        view.sectionHeaderHeight = 45
//        view.estimatedSectionHeaderHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        return view
    }()

}

extension ZKBaseTblView : UITableViewDelegate,UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
