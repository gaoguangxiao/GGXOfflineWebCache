//
//  ZKNavigationView.swift
//
//  Created by 董建伟 on 2021/7/1.


import UIKit
import GGXSwiftExtension
open class ZKNavigationView: ZKBaseView {
    /// 标题
    public var title: String? {
        didSet {
            titleLb.text = title
        }
    }
    /// 标题
    public lazy var titleLb = UILabel().zkTextAlignment(.center).zkFont(.medium16).zkTextColor(.zk333333)
    /// 渐变progress
    public var progress:CGFloat?{
        didSet{
            if let p = progress{
                titleLb.alpha = p
            }
            else{
                titleLb.alpha = 1
            }
        }
    }
    /// 返回
    private var backEvent: ZKVoidClosure?
    /// 位置索引
    private var position: Int = 0
    /// 右侧item点击时间
    private var eventArr: [Int:ZKVoidClosure] = [:]
    
    /// 添加右边item 顺序从右往左
    /// - Parameters:
    ///   - imageName: 图片名字
    ///   - closure: 闭包
    public func addRightItem(imageName:String,_ closure: @escaping ZKVoidClosure){
        let itemBtn = UIButton()
        itemBtn.addTarget(self, action: #selector(itemAction), for: .touchUpInside)
        itemBtn.tag = position
        contentView.addSubview(itemBtn)
        itemBtn.snp.makeConstraints { make in
            make.right.equalTo(-6 - (44) * position)
            make.size.equalTo(44)
            make.centerY.equalTo(titleLb)
        }
        eventArr[position] = closure
        position += 1
    }
    
    /// 添加右边item 顺序从右往左
    /// - Parameters:
    ///   - imageName: 图片名字
    ///   - closure: 闭包
    public func addRightItem(name: String?, _ closure: @escaping ZKVoidClosure){
        let itemBtn = UIButton()
        itemBtn.setTitle(name, for: .normal)
        itemBtn.setTitleColor(.zk3179E5, for: .normal)
        itemBtn.titleLabel?.font = .medium14
        itemBtn.addTarget(self, action: #selector(itemAction), for: .touchUpInside)
        itemBtn.tag = position
        contentView.addSubview(itemBtn)
        itemBtn.snp.makeConstraints { make in
            make.right.equalTo(-8 - (44) * position)
            make.size.equalTo(44)
            make.centerY.equalTo(titleLb)
        }
        eventArr[position] = closure
        position += 1
    }
    
    public func addBackItem(imageName:String, _ closure: @escaping ZKVoidClosure){
        self.addBackItem(closure)
        backBtn.zkNormalHigTDImg(imageName)
//        backBtn.zkNormalBackgroundImage(imageName)
    }
    
    /// 添加返回按钮
    /// - Parameter closure:
    public func addBackItem(_ closure: @escaping ZKVoidClosure){
        contentView.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.equalTo(UIDevice.getSafeAreaLeft == 0 ? 20 : UIDevice.getSafeAreaLeft)
            make.centerY.equalTo(titleLb)
            make.size.equalTo(CGSize(width: 40, height:40.0))
        }
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backEvent = closure
    }
    /// 返回事件
    @objc private func backBtnClick() {
        backEvent?()
    }
    /// 右侧item点击时间
    @objc private func itemAction(sender:UIButton){
        let tag = sender.tag
        if let closure = eventArr[tag]{
            closure()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
//        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: f)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        contentView.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.left.equalTo(60)
            make.right.equalTo(-60)
        }
    }
    
    private lazy var contentView:UIView = UIView()
    
//    var senderBackBtn: UIButton {
//        return self.backBtn
//    }
    
    public lazy var backBtn = UIButton().zkNormalHigTDImg("navBack").zkAction(self, action: #selector(backBtnClick))
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
