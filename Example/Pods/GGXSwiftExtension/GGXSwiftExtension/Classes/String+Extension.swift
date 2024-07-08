//
//  String+Extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/30.
//  Copyright © 2017年 高广校. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit

import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

public extension String {
    var length: Int {
        return count
    }
    
    var range: NSRange {
        return NSRange(location: 0, length: count)
    }
    
    /// 预估尺寸，根据字体、宽度
    func size(font: UIFont, width: CGFloat = SCREEN_WIDTH_STATIC) -> CGSize {
        return (self as NSString).boundingRect(with: CGSize(width: width, height: CGFloat(HUGE)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
    
    /// 预估尺寸，根据字体
    func size(of font: UIFont) -> CGSize {
        return self.boundingRect(with: CGSize(width: Double.greatestFiniteMagnitude, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
    
    /// 预估宽度，根据size
    func width(of font: UIFont, size: CGSize) -> Int {
        let boundingSize = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        let width = Int(boundingSize.width)
        return width + 1
    }
    
    /// 是否包含某个字符串
    func has(_ s: String) -> Bool {
        return range(of: s) != nil
    }
    
    /// 是否包含某个字符串
    /// - Parameters:
    ///   - s: 字符
    ///   - option: 匹配规则
    /// - Returns: <#description#>
    func has(_ s: String, option: String.CompareOptions) -> Bool {
        return range(of: s,options: option) != nil
//        return range(of: s) != nil
    }
    
    /// 分割字符
    func split(_ s: String) -> [String] {
        if s.isEmpty {
            return []
        }
        return components(separatedBy: s)
    }
    
    func range(of searchString: String) -> NSRange {
        return (self as NSString).range(of: searchString)
    }
    
    /// 去掉左右空格
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func replace(_ old: String, new: String) -> String {
        return replacingOccurrences(of: old, with: new, options: NSString.CompareOptions.numeric, range: nil)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        return String(self[..<index(from: to)])
    }
    
    func index(from: Int) -> Index {
        return index(startIndex, offsetBy: from)
    }
    
    func substring(fromIndex: Int, toIndex: Int) -> String {
        let range = NSRange(location: fromIndex, length: toIndex - fromIndex)
        return substr(with: range)
    }
    
    func substr(with range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(endIndex, offsetBy: range.location + range.length - count)
        return String(self[start..<end])
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    func toInt64() -> Int64? {
        return Int64(self)
    }
    
    func toDouble() -> Double {
        return (Double(self) ?? 0)
    }
    
    var md5Value: String {
//        let data = self.data(using: .utf8)
//        Insecure.MD5.hash(data: data)
        if #available(iOS 13.0, *) {
            return Insecure.MD5.hash(data: self.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
        } else {
            // Fallback on earlier versions
            let length = Int(CC_MD5_DIGEST_LENGTH)
            var digest = [UInt8](repeating: 0, count: length)

                    if let d = self.data(using: .utf8) {
                        _ = d.withUnsafeBytes { body -> String in
                            CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)

                            return ""
                        }
                    }

                    return (0 ..< length).reduce("") {
                        $0 + String(format: "%02x", digest[$1])
                    }
        }
    }
}

//MARK: 字符串操作
public extension String {

    static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    static func randomString(length : Int) -> String{
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}

// MARK: - URL Encode & Decode
public extension String {
        
    var toUrl: URL? {
        if let url = URL.init(string: self) {
            return url
        }
        let charSet = CharacterSet.urlQueryAllowed as NSCharacterSet
        let mutSet = charSet.mutableCopy() as! NSMutableCharacterSet
        mutSet.addCharacters(in: "#")
        let result = self.addingPercentEncoding(withAllowedCharacters: mutSet as CharacterSet)
        return URL(string: result ?? "")
    }
    
    var toFileUrl: URL? {
        var url : URL?
        
        let charSet = CharacterSet.urlQueryAllowed as NSCharacterSet
        let mutSet = charSet.mutableCopy() as! NSMutableCharacterSet
        mutSet.addCharacters(in: "#")
        let result = self.addingPercentEncoding(withAllowedCharacters: mutSet as CharacterSet)
        
        if #available(iOS 16.0, *) {
            url = URL(filePath: result ?? "" )
        } else {
            // Fallback on earlier versions
            url = URL(fileURLWithPath: result ?? "")
        }
        return url
    }
    
    var URLEncode: String {
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        let unreservedCharset = CharacterSet(charactersIn: unreservedChars)
        
        return addingPercentEncoding(withAllowedCharacters: unreservedCharset) ?? self
    }
    
    var URLDecode: String {
        return removingPercentEncoding ?? self
    }
    
    var URLAddingPercentEncodingInQuery: String {
        let allowedCharacters = CharacterSet.urlQueryAllowed
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }
    
    var urlParamterEncode: String {
        func encodeParamterValue(paramter: String) -> String {
            let query = paramter.components(separatedBy: "=")
            guard query.count == 2 else { return paramter }
            let key: String = query.first ?? ""
            let value: String = query.last ?? ""
            let encodeParamter = "\(key)=\(value.URLEncode)"
            return encodeParamter
        }
        
        guard !self.isEmpty else { return self }
        let baseUrl = "?"
        guard self.contains(baseUrl) && (self.hasPrefix("https://") || self.hasPrefix("http://"))
        else { return self }
        
        let range = self.range(of: baseUrl)
        // get  "https://www.baidu.com?"
        let headerStrig = self.substring(to: range.location + range.length)
        // get key1=value1&key2=value2
        let paramterString = self.substring(from: range.location + range.length)
        // encode paramter
        var paramters = paramterString.components(separatedBy: "&")
        guard !paramters.isEmpty else { return self }
        for i in 0...paramters.count - 1 {
            var paramter = paramters[i]
            paramter = encodeParamterValue(paramter: paramter)
            paramters[i] = paramter
        }
        let encodeString = "\(paramters.joined(separator: "&"))"
        
        return "\(headerStrig)\(encodeString)"
    }
    
    var toPath: String {
        guard let url = self.toUrl else { return "" }
        if #available(iOS 16.0, *) {
            return url.path()
        } else {
            // Fallback on earlier versions
            return url.path
        }
    }
    
    var toHost: String? {
        guard let url = self.toUrl else { return "" }
        if #available(iOS 16.0, *) {
            return url.host()
        } else {
            // Fallback on earlier versions
            return url.host
        }
    }
        
    func getMIMETypeFromPathExtension() -> String {
        var MIMEType = "text/html"
        let pathExtension = self.pathExtension
        if pathExtension == "html" {
            MIMEType = "text/html"
        } else if pathExtension == "js"{
            MIMEType = "application/javascript";
        } else if pathExtension == "css"{
            MIMEType = "text/css";
        } else if pathExtension == "png"{
            MIMEType = "image/png"
        } else if pathExtension == "jpg"{
            MIMEType = "image/jpg"
        } else if pathExtension == "jpeg"{
            MIMEType = "image/jpeg"
        } else if pathExtension == "json"{
            MIMEType = "application/json"
        } else if pathExtension == "xml"{
            MIMEType = "application/xml"
        } else if pathExtension == "pdf"{
            MIMEType = "application/pdf"
        } else if pathExtension == "webp"{
            MIMEType = "image/webp"
        } else if pathExtension == "gif"{
            MIMEType = "application/gif"
        } else if pathExtension == "mp3"{
            MIMEType = "audio/mpeg"
        } else if pathExtension == "mp4"{
            MIMEType = "video/mp4"
        } else if pathExtension == "wav"{
            MIMEType = "audio/wav"
        } else if pathExtension == "ico"{
            MIMEType = "image/x-icon"
        } else if pathExtension == "svg"{
            MIMEType = "image/svg+xml"
        } else if pathExtension == "ttf"{
            MIMEType = "font/ttf"
        } else if pathExtension == "woff"{
            MIMEType = "font/woff"
        } else if pathExtension == "woff2"{
            MIMEType = "font/woff2"
        }
        return MIMEType;
    }
}

// MARK: Function of NSString
public extension String {
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    var stringByDeletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    var stringByDeletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
}

// MARK: 正则匹配
public extension String {

    /*
     
      https://www.jianshu.com/p/55d7c2d51d13
     
      ^  表示匹配字符串开始的位置（若干用在[]之外，则表示取反，表示不匹配括号中字符串）
      $  表示匹配字符串的结束位置
      [] 中括号表示 匹配括号中一个字符
      {} 大括号表示 限定匹配次数，如{n}代表匹配n个字符，{n,}表示至少匹配n个字母，{n,m}至少n,最多m
      \d 表示数字[0-9]，0-9的数字
      \D 表示非数字
     **/

    
    
//    ^1[0-9]{10}$ 或者 ^1\\d{10}$

    //匹配手机号
    //在Swift5.0原始字符串使用字符串插值时，必须反斜杠使用#号。Swift4.2需要转义反斜杠
    var isPhoneNunber: Bool {
//        return self.verification(pattern: "^1\\d{10}$")
        //swift5.0版本
        return self.verification(pattern: #"^1\d{10}$"#)
    }
    /// 核实合法手机号码
    func isValidPhoneNumber() -> Bool { self.verification(pattern: "^1\\d{10}$") }
    
    /// 验证字符串匹配结果是否符合要求，返回布尔值
    func verification(pattern: String) -> Bool { (self.matching(pattern: pattern)?.count ?? 0) > 0 }
    
    /// 获取匹配结果的数组
    func matching(pattern: String, options: NSRegularExpression.Options = .caseInsensitive) -> [NSTextCheckingResult]? {
        let regex = try? NSRegularExpression(pattern: pattern, options: options)
        return regex?.matches(in: self, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, self.count))
    }
    
//    func replaceNonEnglishCharactersWithSpaces(text: String) -> String {
//        let nonEnglishCharactersRange = NSMakeRange(0, text.utf16.count)
//        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z]", options: [])
//        let modifiedString = regex.stringByReplacingMatches(in: text, options: [], range: nonEnglishCharactersRange, withTemplate: " ")
//        return modifiedString
//    }
    
    /// 替换字符
    func replace(pattern:String,replacement:String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        return regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count), withTemplate: replacement)
    }
   
}

//MARK: 图片base64
public extension String {
    /// 图片base64转Data数据
    ///
    var base64Image: UIImage? {
        if let base64Data = convertImageBase64ToImageData(imageBase64Str: self){
            return UIImage.init(data: base64Data)!
        }
        return nil
    }
    
    func convertImageBase64ToImageData(imageBase64Str: String) -> Data? {
        var base64String = imageBase64Str

        if base64String.hasPrefix("data:image") {
            guard let newBase64String = base64String.components(separatedBy: ",").last else {
                return nil
            }
            base64String = newBase64String
        }
        guard let decodedData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return decodedData
    }
    
}
