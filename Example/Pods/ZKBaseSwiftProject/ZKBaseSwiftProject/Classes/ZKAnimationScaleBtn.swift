//
//  ZKAnimationScaleBtn.swift
//  RSBridgeLogin
//
//  Created by 高广校 on 2024/3/25.
//  com.readadventure.app.product.continue_buy.vip428_1


import Foundation

/// 动画协议
public protocol AnimationScaleProtocol {
    
    var duration: CGFloat {set get}
    
    var scale: CGFloat {set get}
    
    func resetLoginBtnStatus()
}

//实现一个点击时的放大缩小动画
public class ZKAnimationScaleBtn: UIButton, AnimationScaleProtocol {
    
    public var duration: CGFloat = 0.2
    
    public var scale: CGFloat = 0.6
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(zkTouchDragInside), for: .touchDragInside)
        addTarget(self, action: #selector(zkTouchDown), for: .touchDown)
        addTarget(self, action: #selector(zkTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(zkTouchDragExit), for: .touchDragExit)
        //        if #available(iOS 15.0, *) {
        
        //        } else {
        // Fallback on earlier versions
        //默认为YES。如果是，当高亮显示(按下)时，图像绘制得更暗
        self.adjustsImageWhenHighlighted = false
        //        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 控件按压
    @objc func zkTouchDown(sender: UIButton) {
        //        print("控件按压")
        UIView.animate(withDuration: duration) {
            sender.transform = CGAffineTransformMakeScale(self.scale, self.scale)
        }
    }
    
    @objc func zkTouchUpInside(sender: UIButton) {
        //        print("控件点击")
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            sender.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        }
        animator.addAnimations({
            sender.transform = .identity
        }, delayFactor: 0.1)
        animator.startAnimation()
    }
    
    /// 控件内拖动时
    @objc func zkTouchDragInside(_ sender: UIButton) {
        
    }
    
    /// 从控件内拖动到外部时
    @objc func zkTouchDragExit(sender: UIButton) {
        //        print("控件内拖动到外部时")
        UIView.animate(withDuration: 0.15) {
            sender.transform = .identity
        }
    }
}

extension ZKAnimationScaleBtn {
    
    public func resetLoginBtnStatus() {
        UIView.animate(withDuration: 0.15) {
            self.transform = .identity
        }
    }
    
}
