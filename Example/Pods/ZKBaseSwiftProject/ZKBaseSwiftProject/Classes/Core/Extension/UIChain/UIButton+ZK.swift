//
//  UIButton+ZK.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import UIKit

public extension UIButton {
    
    //MARK: - 文字颜色
    
    //普通+点击效果
    @discardableResult
    func zkNormalHigTitleColor(_ color: UIColor?) -> Self {
        setTitleColor(color, for: .normal)
        setTitleColor(color, for: .highlighted)
        return self
    }
    
    //选中效果
    @discardableResult
    func zkSetTitleColor(_ color: UIColor?) -> Self {
        setTitleColor(color, for: .normal)
        return self
    }
    
    @discardableResult
    func zkFont(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
    
    @discardableResult
    func zkSetNormalTitleColor(_ color: UIColor?) -> Self {
        setTitleColor(color, for: .normal)
        return self
    }
    
    @discardableResult
    func zkSetDisabledTitleColor(_ color: UIColor?) -> Self {
        setTitleColor(color, for: .disabled)
        return self
    }
    
    @discardableResult
    func zkSetTitleColor(_ color: UIColor?, for state: UIControl.State) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    
    @discardableResult
    func zkSetAttributedTitle(_ title: NSAttributedString, for state: UIControl.State) -> Self {
        setAttributedTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func zkSetNormalTitle(_ title: String) -> Self {
        setTitle(title, for: .normal)
        return self
    }
    
    
    @discardableResult
    func zkSetTitle(_ title: String, for state: UIControl.State) -> Self {
        setTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func zkAction(_ target:Any, action: Selector) -> Self {
        addTarget(target, action: action, for: .touchUpInside)
        return self
    }
    
    @discardableResult
    func zkNormalHigTDImg(_ imgName: String?) -> Self {
        let image = UIImage(named: imgName ?? "")
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
        return self
    }
    
    @discardableResult
    func zkNormalImgName(_ imgName: String?) -> Self {
        setImage(UIImage(named: imgName ?? ""), for: .normal)
        return self
    }
    
    //MARK: - 背景
    @discardableResult
    func zkNormalBackgroundImage(_ imgName: String?) -> Self {
        setBackgroundImage(UIImage(named: imgName ?? ""), for: .normal)
        return self
    }
    
    @discardableResult
    func zkNormalBackgroundImage(_ image: UIImage) -> Self {
        setBackgroundImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    func zkSelectImgName(_ imgName: String?) -> Self {
        setImage(UIImage(named: imgName ?? ""), for: .selected)
        return self
    }
    
    @discardableResult
    func zkSelectBackgroundImage(_ imgName: String?) -> Self {
        setBackgroundImage(UIImage(named: imgName ?? ""), for: .selected)
        return self
    }
    
    //
    @discardableResult
    func zkBackgroundNomalImage(_ image: UIImage) -> Self {
        setBackgroundImage(image, for: .normal)
//        setBackgroundImage(image, for: .highlighted)
        return self
    }
    
}


extension UIButton {
    

    @discardableResult
    func normalTitleColor(_ color: UIColor?) -> Self {
        setTitleColor(color, for: .normal)
        return self
    }
    
    @discardableResult
    func disabledTitleColor(_ color: UIColor?) -> Self {
        setTitleColor(color, for: .disabled)
        return self
    }
    
    @discardableResult
    func titleColor(_ color: UIColor?, for state: UIControl.State) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    
    @discardableResult
    func normalTitle(_ title: String) -> Self {
        setTitle(title, for: .normal)
        return self
    }
    
    @discardableResult
    func title(_ title: String, for state: UIControl.State) -> Self {
        setTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func action(_ target:Any, action: Selector) -> Self {
        addTarget(target, action: action, for: .touchUpInside)
        return self
    }
    
    @discardableResult
    func backgroundImage(_ bkImg: UIImage?) -> Self {
        setBackgroundImage(bkImg, for: .normal)
        return self
    }
    
    
    @discardableResult
    func bkColor (_ bkColor: UIColor?) -> Self {
        backgroundColor = bkColor
        return self
    }
    
    @discardableResult
    func image(_ img:UIImage?, for state: UIControl.State) -> Self {
        setImage(img, for: state)
        return self
    }
    
    @discardableResult
    func normalImg(_ img: UIImage?) -> Self {
        setImage(img, for: .normal)
        return self
    }
    
    @discardableResult
    func highlightedImg(_ img: UIImage?) -> Self {
        setImage(img, for: .highlighted)
        return self
    }
    
    @discardableResult
    func selectImg(_ img: UIImage?) -> Self {
        setImage(img, for: .selected)
        setImage(img, for: .highlighted)
        setImage(img, for: UIControl.State(rawValue: (UIControl.State.selected.rawValue)|(UIControl.State.highlighted.rawValue)))
        return self
    }
    
}

var ZKExpandSizeKey = "ZKExpandSizeKey"

extension UIButton {
    
    func zkExpandSize(_ size: CGFloat) {
        objc_setAssociatedObject(self, &ZKExpandSizeKey, size, .OBJC_ASSOCIATION_COPY)
    }
    
    private func expandRect() -> CGRect {
        let expandSize = objc_getAssociatedObject(self, &ZKExpandSizeKey)
        if (expandSize != nil) {
            return CGRect(x: bounds.origin.x - (expandSize as! CGFloat), y: bounds.origin.y - (expandSize as! CGFloat), width: bounds.size.width + 2*(expandSize as! CGFloat), height: bounds.size.height + 2*(expandSize as! CGFloat))
        }else{
            return bounds;
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let buttonRect = expandRect()
        if (buttonRect.equalTo(bounds)) {
            return super.point(inside: point, with: event)
        }else{
            return buttonRect.contains(point)
        }
    }
}
