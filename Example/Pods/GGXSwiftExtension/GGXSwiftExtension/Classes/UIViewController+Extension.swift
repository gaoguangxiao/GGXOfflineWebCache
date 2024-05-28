//
//  UIViewController+Extension.swift
//  RSReading
//
//  Created by 高广校 on 2023/10/27.
//
/**
 请主项目实现一下方法
         if let app = UIApplication.shared.delegate as? AppDelegate {
             switch orientation {
             case .portrait:
                 app.orientationMask = .portrait
             case .landscapeRight:
                 app.orientationMask = .landscapeRight
             case .landscapeLeft:
                 app.orientationMask = .landscapeLeft
             case .portraitUpsideDown:
                 app.orientationMask = .portraitUpsideDown
             default:
                 break
             }
 //
 */

import Foundation

public extension UIViewController{
    //当pushvc的时候对tabbar隐藏
    convenience init(nibName:String) {
        
        if !nibName.isEmpty {
            self.init(nibName: nibName, bundle: nil)
        }else{
            self.init()
        }
        self.hidesBottomBarWhenPushed = true
    }

    //隐藏键盘
    func hideKeyBoard()  {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func callTel(to tel:String)  {
        if let url = URL.init(string: "tel://\(tel)"),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        } else {
//            self.showHint("设备不支持")
        }
    }
    
    func push(_ vc:UIViewController, _ animated:Bool = true) {
        if self.navigationController != nil{
            self.navigationController?.pushViewController(vc, animated: animated)
        }else{
            print("NavigationController is nil")
        }
    }
    
    func dis(_ animated:Bool = true){
        if self.navigationController != nil{
            _ = self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
            print("NavigationController is nil")
        }
    }
    
    func pop(_ animated:Bool = true){
        if self.navigationController != nil{
            _ = self.navigationController?.popViewController(animated: animated)
        }else{
            print("NavigationController is nil")
        }
    }
    
    func popToRoot(_ animated:Bool = true){
        if self.navigationController != nil{
            _ = self.navigationController?.popToRootViewController(animated: animated)
        }else{
            print("NavigationController is nil")
        }
    }

}

//横竖屏
extension UIViewController {
    func p_switchOrientationWithLaunchScreen(isLaunchScreen:Bool) {
        self .p_switchOrientationWithLaunchScreen(orientation: isLaunchScreen ? UIInterfaceOrientationMask.landscapeLeft : UIInterfaceOrientationMask.portrait)
    }
    
    public func p_switchOrientationWithLaunchScreen(orientation:UIInterfaceOrientationMask) {
        if #available(iOS 13.0, *) {
            if let scene = UIApplication.windowScenes.first{
                if #available(iOS 16.0, *) {
                    self.setNeedsUpdateOfSupportedInterfaceOrientations()
                    let geometryPreferencesIOS = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)
                    scene.requestGeometryUpdate(geometryPreferencesIOS) { error in
//                        print("横屏结果\(error)")
                    }
                } else {
                    // Fallback on earlier versions
                    p_switchLowOrientationWithLaunchScreen(orientation: orientation)
                }
            }
        } else {
            // Fallback on earlier versions
            p_switchLowOrientationWithLaunchScreen(orientation: orientation)
        }
    }
    
    public func p_switchLowOrientationWithLaunchScreen(orientation: UIInterfaceOrientationMask) {
        var deviceInt: UIDeviceOrientation = .portrait
        if orientation == .landscape {
            deviceInt = .landscapeLeft
        } else {
            deviceInt = .portrait
        }
        let ori = NSNumber(integerLiteral: deviceInt.rawValue)
        UIDevice.current.setValue(ori, forKey: "orientation")
    }
}
