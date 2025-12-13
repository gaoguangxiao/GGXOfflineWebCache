//
//  UIView+ZK.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import UIKit

/**
 let s = ZKVIew(UIVIew()).view
 **/
@dynamicMemberLookup
public struct ZKView<View> {
    
    public let view : View
    
    public init(_ view: View) {
        self.view = view
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<View, Value>) -> ((Value) -> ZKView<View>) {
        // 获取到真正的对象
        var subject = self.view
        return { value in
            // 把 value 指派给 subject
            subject[keyPath: keyPath] = value
            // 回传的类型是 ZKView<View> 而不是 View
            // 因为使用ZKView来链式，而不是 View 本身
            return ZKView(subject)
        }
    }
}

/**
 扩展初始化方法
 */
public extension UIView {
    
    @discardableResult
    func zkBorder(_ color:UIColor, _ width:CGFloat) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        layer.masksToBounds = true
        return self
    }
    
    
    @discardableResult
    func zkLayerCornerRadius(_ r:CGFloat) -> Self {
        layer.cornerRadius = r
        layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func zkFrame(_ f: CGRect) -> Self {
        frame = f
        return self
    }
    
    @discardableResult
    func zkBackgroundColor(_ color:UIColor?) -> Self {
        backgroundColor = color
        return self
    }
    
    @discardableResult
    func zkAlpha(_ aAlpha: CGFloat) -> Self {
        alpha = aAlpha
        return self
    }
    
    @discardableResult
    func zkTag(_ aTag: Int) -> Self {
        tag = aTag
        return self
    }
    
    @discardableResult
    func zkIsHidden(_ hidden: Bool) -> Self {
        isHidden = hidden
        return self
    }
}

/**
  链式语法
 */
extension UIView {
    
    @discardableResult
    func frame(_ f: CGRect) -> Self {
        frame = f
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color:UIColor?) -> Self {
        backgroundColor = color
        return self
    }
    
    @discardableResult
    func alpha(_ aAlpha: CGFloat) -> Self {
        alpha = aAlpha
        return self
    }
    
    @discardableResult
    func tag(_ aTag: Int) -> Self {
        tag = aTag
        return self
    }
    
    @discardableResult
    func isHidden(_ hidden: Bool) -> Self {
        isHidden = hidden
        return self
    }
    
    /// 通过td变量引入UIView的扩展
    var td: TDViewExt {
        return TDViewExt(view: self)
    }
}

/// UIView的扩展
public struct TDViewExt {
    
    internal let view: UIView
    
    internal init(view: UIView) {
        self.view = view
    }
    
    /// 移除所有的子View
    func removeAllSubviews(){
        for view in view.subviews {
            view.removeFromSuperview()
        }
    }
    
    /// 根据tag移除view
    /// - Parameter tag: tag
    func removeSubview(tag:Int){
        for view in view.subviews {
            if view.tag == tag{
                view.removeFromSuperview()
            }
        }
    }
    //添加多个View
    func addSubviews(_ subviews:[UIView]){
        for v in subviews {
            view.addSubview(v)
        }
    }
    
    public var x: CGFloat{
        get{
            return view.frame.origin.x
        }
        set{
            var r = view.frame
            r.origin.x = newValue
            view.frame = r
        }
    }
    
    public var y: CGFloat{
        get{
            return view.frame.origin.y
        }
        set{
            var r = view.frame
            r.origin.y = newValue
            view.frame = r
        }
    }
    /// 右边界的x值
    public var rightX: CGFloat{
        get{
            return x + width
        }
        set{
            var r = view.frame
            r.origin.x = newValue - view.frame.size.width
            view.frame = r
        }
    }
    /// 下边界的y值
    public var bottomY: CGFloat{
        get{
            return y + height
        }
        set{
            var r = view.frame
            r.origin.y = newValue - view.frame.size.height
            view.frame = r
        }
    }
    
    public var centerX : CGFloat{
        get{
            return view.center.x
        }
        set{
            view.center = CGPoint(x: newValue, y: view.center.y)
        }
    }
    
    public var centerY : CGFloat{
        get{
            return view.center.y
        }
        set{
            view.center = CGPoint(x: view.center.x, y: newValue)
        }
    }
    
    public var width: CGFloat{
        get{
            return view.frame.size.width
        }
        set{
            var r = view.frame
            r.size.width = newValue
            view.frame = r
        }
    }
    public var height: CGFloat{
        get{
            return view.frame.size.height
        }
        set{
            var r = view.frame
            r.size.height = newValue
            view.frame = r
        }
    }
    
    
    public var origin: CGPoint{
        get{
            return view.frame.origin
        }
        set{
            x = newValue.x
            y = newValue.y
        }
    }
    
    public var size: CGSize{
        get{
            return view.frame.size
        }
        set{
            width = newValue.width
            height = newValue.height
        }
    }
    
    public var bottom: CGFloat{
        get{
            return y + height
        }
        set{
            var r = view.frame
            r.origin.y = newValue - view.frame.size.height
            view.frame = r
        }
    }
    
}


extension UIView {
    
    func zkAddCorner(roundingCorners: UIRectCorner, cornerSize: CGSize) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
        let cornerLayer = CAShapeLayer()
        cornerLayer.frame = bounds
        cornerLayer.path = path.cgPath
        layer.mask = cornerLayer
    }
}


extension UIView {
    
    /// 此方法是用来规范更新视图方法
    /// - Parameter model: 数据源
    @objc open func updateUI(_ model: ZKBaseModel?) {
        
    }
    
    /// 初始化视图需要，可UIView()
    @objc open func initViewUI(_ model: ZKBaseModel?) {
        
    }
}

@objc extension UIView {
    
    @objc enum ShadowType: Int {
        case all = 0 ///四周
        case top  = 1 ///上方
        case left = 2///左边
        case right = 3///右边
        case bottom = 4///下方
    }

    ///默认设置：黑色阴影
    func shadow(_ type: ShadowType) {
        shadow(type: type, color: .zkB6CDEF, opactiy: 0.4, shadowSize: 1)
    }
    
    ///常规设置
    func shadow(type: ShadowType, color: UIColor,  opactiy: Float, shadowSize: CGFloat) -> Void {
        layer.masksToBounds = false;//必须要等于NO否则会把阴影切割隐藏掉
        layer.shadowColor = color.cgColor;// 阴影颜色
        layer.shadowOpacity = opactiy;// 阴影透明度，默认0
        layer.shadowOffset = .zero;//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
        layer.shadowRadius = 3 //阴影半径，默认3
        var shadowRect: CGRect?
        switch type {
        case .all:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .top:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .bottom:
            shadowRect = CGRect.init(x: -shadowSize, y: bounds.size.height - shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .left:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .right:
            shadowRect = CGRect.init(x: bounds.size.width - shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        }
        layer.shadowPath = UIBezierPath.init(rect: shadowRect!).cgPath
    }
}

@objc public extension UIView {
   
    func defaultEmptyView() {
        defaultEmptyView("暂无内容")
    }
    
    ///默认设置：缺省页
    func defaultEmptyView(_ title: String = "暂无内容") {
//        let emptyV = LYEmptyView.empty(withImageStr: "configEmpty_View", titleStr: title, detailStr: nil)
//        self.ly_emptyView = emptyV
//        self.ly_emptyView.isHidden = true
    }
}
