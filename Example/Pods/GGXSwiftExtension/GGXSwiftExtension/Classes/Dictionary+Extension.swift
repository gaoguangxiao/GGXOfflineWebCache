//
//  Dictionary+CommonExtension.swift
//  DaDaClass
//
//  Created by han wp on 2018/4/10.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

public extension Dictionary {
    var toQueryStr: String {
        return self.reduce("") { $0 + ($0 == "" ? "" : "&") + "\($1.0)=\($1.1)" }
    }

    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }

    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
    
    var toJsonString: String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    func decode<T: Decodable>(type: T.Type) -> T? {
        do {
            guard let jsonStr = self.toJsonString else { return nil }
            guard let jsonData = jsonStr.data(using: .utf8) else { return nil }
            let decoder = JSONDecoder()
            let obj = try decoder.decode(type, from: jsonData)
            return obj
        } catch let error {
            print(error)
            return nil
        }
    }
    
    /// 字典到json字符串
    var toPrettyString: String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

public extension Dictionary where Key: Comparable, Value: Equatable {

//    A与B的交集
    func minus(dict: [Key: Value]) -> [Key: Value] {
        let entriesInSelfAndDict = filter {
            return dict[$0.0] == self[$0.0]
        }
        return entriesInSelfAndDict
    }

//    (a与b的交集)的非集
    func diff(dict: [Key: Value]) -> [Key: Value] {
        let wholeDict = self.reduce(dict) { (res, entry) -> [Key: Value] in
            var res = res
            res[entry.0] = entry.1
            return res
        }
        let minus = self.minus(dict: dict)
        let diff = wholeDict.filter { wholeDict[$0.0] != minus[$0.0] }
        return diff
    }
}
