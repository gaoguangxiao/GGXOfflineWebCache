//
//  ZKBaseTblViewController.swift
//  ZKNASProj
//
//  Created by gaoguangxiao on 2022/11/15.
//

import UIKit
import GGXSwiftExtension
open class ZKBaseTblViewController: ZKBaseViewController {

    public var dataArray: [Any] = []
    
    var tableView: UITableView?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view => tbl
        
        tbl.snp.makeConstraints { make in
            make.top.equalTo(TopBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView = tbl
    }
    
    private lazy var tbl: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.rowHeight = 40
        //view.estimatedRowHeight = UITableView.automaticDimension
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


extension ZKBaseTblViewController : UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
