//
//  UIImage+CommonExtension.swift
//  DaDaClass
//
//  Created by han wp on 2018/4/10.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import UIKit

public enum DDUIImageShape {
    case oval // 椭圆
    case triangle // 三角形
    case disclosureIndicator // 列表cell右边的箭头
    case checkmark // 列表cell右边的checkmark
    case navBack // 返回按钮的箭头
    case navClose // 导航栏的关闭icon
}

public extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 0.5)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = image, let ciimg = img.cgImage {
            self.init(cgImage: ciimg)
        } else {
            self.init()
        }
    }
    
    /**
     *  判断一张图是否不存在 alpha 通道，注意 “不存在 alpha 通道” 不等价于 “不透明”。一张不透明的图有可能是存在 alpha 通道但 alpha 值为 1。
     */
    var opaque: Bool {
        guard let ciimg = cgImage else {
            return false
        }
        let alphaInfo = ciimg.alphaInfo
        let opaque = alphaInfo == .noneSkipLast
        || alphaInfo == .noneSkipFirst
        || alphaInfo == .none
        return opaque
    }
    
    /**
     *  在当前图片的上下左右增加一些空白（不支持负值），通常用于调节NSAttributedString里的图片与文字的间距
     *  @param extension 要拓展的大小
     *  @return 拓展后的图片
     */
    func imageWithSpacingExtensionInsets(_ insets: UIEdgeInsets) -> UIImage? {
        let contextSize = CGSize(width: size.width + insets.horizontalValue, height: size.height + insets.verticalValue)
        UIGraphicsBeginImageContextWithOptions(contextSize, opaque, scale)
        draw(at: CGPoint(x: insets.left, y: insets.top))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
    
    /**
     *  将原图进行旋转，只能选择上下左右四个方向
     *
     *  @param  orientation 旋转的方向
     *
     *  @return 处理完的图片
     */
    @objc func image(with orientation: UIImage.Orientation) -> UIImage {
        if orientation == .up {
            return self
        }
        
        var contextSize = size
        if orientation == .left || orientation == .right {
            contextSize = CGSize(width: contextSize.height, height: contextSize.width)
        }
        
        contextSize = contextSize.flatSpecific(scale: scale)
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // 画布的原点在左上角，旋转后可能图片就飞到画布外了，所以旋转前先把图片摆到特定位置再旋转，图片刚好就落在画布里
        switch orientation {
        case .up:
            // 上
            break
        case .down:
            // 下
            context.translateBy(x: contextSize.width, y: contextSize.height)
            context.rotate(by: AngleWithDegrees(180))
        case .left:
            // 左
            context.translateBy(x: 0, y: contextSize.height)
            context.rotate(by: AngleWithDegrees(-90))
        case .right:
            // 右
            context.translateBy(x: contextSize.width, y: 0)
            context.rotate(by: AngleWithDegrees(90))
        case .downMirrored, .upMirrored:
            // 向上、向下翻转是一样的
            context.translateBy(x: 0, y: contextSize.height)
            context.scaleBy(x: 1, y: -1)
        case .rightMirrored, .leftMirrored:
            // 向左、向右翻转是一样的
            context.translateBy(x: contextSize.width, y: 0)
            context.scaleBy(x: -1, y: 1)
        @unknown default:
            break
        }
        
        // 在前面画布的旋转、移动的结果上绘制自身即可，这里不用考虑旋转带来的宽高置换的问题
        draw(in: size.rect)
        
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut ?? self
    }
    
    /**
     *  将原图进行镜像
     *
     *  @param  orientation 旋转的方向
     *
     *  @return 处理完的图片
     */
    @objc func mirror() -> UIImage {
        let flipImageOrientation = (self.imageOrientation.rawValue + 4) % 8
        let flipImage = UIImage(cgImage:self.cgImage!, scale:self.scale,orientation:UIImage.Orientation(rawValue: flipImageOrientation)!)
        return flipImage
    }
    
    /**
     *  创建一个纯色的UIImage
     *
     *  @param  color           图片的颜色
     *  @param  size            图片的大小
     *  @param  cornerRadius    图片的圆角
     *
     * @return 纯色的UIImage
     */
    @objc static func image(withColor color: UIColor, size: CGSize, cornerRadius: CGFloat = 0) -> UIImage? {
        let size = size.flatted
        
        if cornerRadius == 0 {
            UIGraphicsBeginImageContext(size)
            color.set()
            UIRectFill(CGRect(origin: CGPoint.zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        var resultImage: UIImage?
        
        let opaque = (cornerRadius == 0.0 && color.alphaValue == 1.0)
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        
        let path = UIBezierPath(roundedRect: size.rect, cornerRadius: cornerRadius)
        path.addClip()
        path.fill()
        
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    /**
     *  创建一个指定大小和颜色的形状图片
     *  @param shape 图片形状
     *  @param size 图片大小
     *  @param tintColor 图片颜色
     */
    static func image(with shape: DDUIImageShape, size: CGSize, tintColor: UIColor) -> UIImage? {
        var lineWidth: CGFloat = 0
        switch shape {
        case .navBack:
            lineWidth = 2.0
        case .disclosureIndicator:
            lineWidth = 1.5
        case .checkmark:
            lineWidth = 1.5
        case .navClose:
            lineWidth = 1.2 // 取消icon默认的lineWidth
        default:
            break
        }
        return image(withShape: shape, size: size, lineWidth: lineWidth, tintColor: tintColor)
    }
    
    /**
     *  创建一个指定大小和颜色的形状图片
     *  @param shape 图片形状
     *  @param size 图片大小
     *  @param lineWidth 路径大小，不会影响最终size
     *  @param tintColor 图片颜色
     */
    static func image(withShape shape: DDUIImageShape, size: CGSize, lineWidth: CGFloat, tintColor: UIColor?) -> UIImage? {
        let size = size.flatted
        
        var resultImage: UIImage?
        let tintColor = tintColor ?? UIColor.white
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        var path: UIBezierPath
        var drawByStroke = false
        let drawOffset = lineWidth / 2
        switch shape {
        case .oval:
            path = UIBezierPath(ovalIn: size.rect)
        case .triangle:
            path = UIBezierPath()
            
            path.move(to: CGPoint(x: 0, y: size.height))
            path.addLine(to: CGPoint(x: size.width / 2, y: 0))
            
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.close()
        case .navBack:
            drawByStroke = true
            path = UIBezierPath()
            path.lineWidth = lineWidth
            path.move(to: CGPoint(x: size.width - drawOffset, y: drawOffset))
            path.addLine(to: CGPoint(x: 0 + drawOffset, y: size.height / 2.0))
            path.addLine(to: CGPoint(x: size.width - drawOffset, y: size.height - drawOffset))
        case .disclosureIndicator:
            path = UIBezierPath()
            drawByStroke = true
            path.lineWidth = lineWidth
            path.move(to: CGPoint(x: drawOffset, y: drawOffset))
            path.addLine(to: CGPoint(x: size.width - drawOffset, y: size.height / 2))
            path.addLine(to: CGPoint(x: drawOffset, y: size.height - drawOffset))
        case .checkmark:
            let lineAngle = CGFloat.pi / 4
            path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width / 3, y: size.height))
            path.addLine(to: CGPoint(x: size.width, y: lineWidth * sin(lineAngle)))
            path.addLine(to: CGPoint(x: size.width - lineWidth * cos(lineAngle), y: 0))
            path.addLine(to: CGPoint(x: size.width / 3, y: size.height - lineWidth / sin(lineAngle)))
            path.addLine(to: CGPoint(x: lineWidth * sin(lineAngle), y: size.height / 2 - lineWidth * sin(lineAngle)))
            path.close()
        case .navClose:
            drawByStroke = true
            path = UIBezierPath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.close()
            path.move(to: CGPoint(x: size.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.close()
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
        }
        
        if drawByStroke {
            context.setStrokeColor(tintColor.cgColor)
            path.stroke()
        } else {
            context.setFillColor(tintColor.cgColor)
            path.fill()
        }
        
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    var circleImage: UIImage? {
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.addEllipse(in: size.rect)
        context?.clip()
        draw(in: size.rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    @objc var width: CGFloat {
        return size.width
    }
    @objc var height: CGFloat {
        return size.height
    }
}

public extension UIImage {
    
    @available(iOS 13.0.0, *)
    func bycustomPreparingThumbnail(ofSize: CGSize) async -> UIImage? {
        if #available(iOS 15.0, *) {
            return self.preparingThumbnail(of: ofSize)
        } else {
            // 参数一：指定将来创建出来的图片大小
            // 参数二：设置是否透明
            // 参数三：是否缩放
            UIGraphicsBeginImageContextWithOptions(ofSize, false, 0)
            draw(in: CGRect(origin: CGPoint.zero, size: ofSize))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let outImg = image {
                return outImg
            } else {
                return self
            }
        }
    }
    
    /// 缩放
    func resize(size: CGSize, scale: CGFloat = 0) -> UIImage {
        let formatSize = CGSize(width: ceil(size.width), height: ceil(size.height))
        UIGraphicsBeginImageContextWithOptions(formatSize, false, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: formatSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let outImg = image {
            return outImg
        } else {
            return self
        }
    }
    
    /// 缩放
    func resizeTo(biggerSide: CGFloat, screenScale: CGFloat = 0) -> UIImage {
        var scale : CGFloat = 1.0
        if size.width > size.height {
            scale = size.width / biggerSide
        }else{
            scale = size.height / biggerSide
        }
        return resize(size: CGSize(width:size.width / scale, height:size.height / scale),
                      scale: screenScale)
    }
    
    /// 切图
    func crop(rect: CGRect, scale: CGFloat = 0) -> UIImage {
        let imageRect = size.rect
        if rect.contains(imageRect), rect != imageRect {
            // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
            return self
        }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let outImg = image {
            return outImg
        } else {
            return self
        }
    }
    
    /**
     *  在当前图片的基础上叠加一张图片，并指定绘制叠加图片的起始位置
     *
     *  叠加上去的图片将保持原图片的大小不变，不被压缩、拉伸
     *
     *  @param image 要叠加的图片
     *  @param point 所叠加图片的绘制的起始位置
     *
     *  @return 返回一张与原图大小一致的图片，所叠加的图片若超出原图大小，则超出部分被截掉
     */
    func imageWithImageAbove(_ image: UIImage, at point: CGPoint) -> UIImage? {
        let imageIn = self
        var imageOut: UIImage?
        UIGraphicsBeginImageContextWithOptions(imageIn.size, opaque, imageIn.scale)
        imageIn.draw(in: imageIn.size.rect)
        image.draw(at: point)
        imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
    }
    
    /**
     *  返回一个被mask的图片
     *
     *  @param maskImage             mask图片
     *  @param usingMaskImageMode    是否使用“mask image”的方式，若为 YES，则黑色部分显示，白色部分消失，透明部分显示，其他颜色会按照颜色的灰色度对图片做透明处理。若为 NO，则 maskImage 要求必须为灰度颜色空间的图片（黑白图），白色部分显示，黑色部分消失，透明部分消失，其他灰色度对图片做透明处理。
     *
     *  @return 被mask的图片
     */
    func image(withMaskImage maskImage: UIImage, usingMaskImageMode: Bool) -> UIImage {
        guard let maskCIImg = maskImage.cgImage else { return self }
        let maskRef = maskCIImg
        var mask: CGImage?
        if usingMaskImageMode {
            // 用CGImageMaskCreate创建生成的 image mask。
            // 黑色部分显示，白色部分消失，透明部分显示，其他颜色会按照颜色的灰色度对图片做透明处理。
            
            guard let maskDataProvider = maskRef.dataProvider else { return self }
            
            mask = CGImage(
                maskWidth: maskRef.width,
                height: maskRef.height,
                bitsPerComponent: maskRef.bitsPerComponent,
                bitsPerPixel: maskRef.bitsPerPixel,
                bytesPerRow: maskRef.bytesPerRow,
                provider: maskDataProvider,
                decode: nil,
                shouldInterpolate: true)
            
        } else {
            /*
             用一个纯CGImage作为mask。这个image必须是单色(例如：黑白色、灰色)、没有alpha通道、不能被其他图片mask。
             系统的文档：If `mask' is an image, then it must be in a monochrome color space (e.g. DeviceGray, GenericGray, etc...),
             may not have alpha, and may not itself be masked by an image mask or a masking color.
             */
            // 白色部分显示，黑色部分消失，透明部分消失，其他灰色度对图片做透明处理。
            mask = maskRef
        }
        
        guard let finalMaskImg = mask,
              let maskedImage = cgImage?.masking(finalMaskImg) else {
            return self
        }
        
        let returnImage = UIImage(cgImage: maskedImage, scale: scale, orientation: imageOrientation)
        return returnImage
    }
    
    /**
     *  将文字渲染成图片，最终图片和文字一样大
     */
    static func image(withAttributedString attributedString: NSAttributedString) -> UIImage? {
        // TODO: 归到NSAttributedString的扩展中
        let stringSize = attributedString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size.sizeCeil
        UIGraphicsBeginImageContextWithOptions(stringSize, false, 0)
        _ = UIGraphicsGetCurrentContext()
        
        attributedString.draw(in: stringSize.rect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    /**
     *  修正图片方向
     */
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        draw(in: CGRect(origin: .zero, size: size))
        
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    
    
}

public extension UIImage {
    
    /// 生成单色图
    func getColorfulImg(color: UIColor) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let ciimage = CIImage(cgImage: cgimage)
        let filter = CIFilter(name: "CIFalseColor")
        filter?.setValue(ciimage, forKey: "inputImage")
        filter?.setValue(CIColor(color: UIColor.black), forKey: "inputColor0")
        filter?.setValue(CIColor(color: color), forKey: "inputColor1")
        let finalImg = filter?.outputImage
        if let output = finalImg {
            return UIImage(ciImage: output)
        }
        return  self
    }
}

//qrcode

public class QRCreateModel {
    
    /// 文本
    public var text: String?
    
    /// 二维码中间的logo
    public var logo: String?
    
    /// 二维码缩放倍数{27*scale,27*scale}
    public var scale: Float = 10
    
    /// 二维码背景颜色
    public var backgroundColor: UIColor = UIColor.white
    
    /// 二维码颜色
    public var contentColor: UIColor = UIColor.black
    
    public init(text: String, logo: String? = nil, scale: Float = 10, backgroundColor: UIColor = .white, contentColor: UIColor = .black) {
        self.text = text
        self.logo = logo
        self.scale = scale
        self.backgroundColor = backgroundColor
        self.contentColor = contentColor
    }
}

public extension UIImage {
    
    private static func addLogo(ciImage: CIImage, model: QRCreateModel) -> UIImage? {
        
        guard let _ = model.logo,
              let logoImage = UIImage(named: model.logo!) else {
            
            return nil
        }
        
        let image = UIImage(ciImage: ciImage)
        let originX = (image.size.width - logoImage.size.width)/2.0
        let originY = (image.size.height - logoImage.size.height)/2.0
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        logoImage.draw(in: CGRect(x: originX, y: originY, width: logoImage.size.width, height: logoImage.size.height))
        
        let outPutImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outPutImage
    }
    
    static func createQRCode(model: QRCreateModel) -> UIImage? {
        
        guard let qrCode = model.text else { return nil }
        
        guard let data = qrCode.data(using: .utf8) else { return nil }
        
        let filter = CIFilter(name: "CIQRCodeGenerator",parameters: ["inputMessage":data,
                                                                     "inputCorrectionLevel":"Q"])
        
        // 创建一个 CIContext 对象：
        let context = CIContext()
        
        let transformed = CGAffineTransform(scaleX: 10, y: 10)
        
        // 获取生成的二维码图像
        if let outputImage = filter?.outputImage?.transformed(by: transformed) {
            // 将图像转换为可显示的 CGImage
            
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                // 创建 UIImage 并显示
                let qrCodeImage = UIImage(cgImage: cgImage)
                
                guard let qrImageWithLogo = addLogo(ciImage: outputImage, model: model) else {

                    return qrCodeImage
                }
  
                return qrImageWithLogo
            }
        }
        return nil
    }
}
