//
//  Task+Extension.swift
//  GGXSwiftExtension
//
//  Created by 高广校 on 2024/7/22.
//

import Foundation

public typealias RetryPredicateBool = @Sendable (any Error) -> Bool

@available(iOS 13.0, *)
extension Task where Failure == Error {

    ///       Task {
    ///            let result = await Task.retrying {
    ///                try await self.requestModelApiThrows(paras: "1")
    ///            }.result
    ///            switch result {
    ///            case .success(let success):
    ///            case .failure(let failure):
    ///            }
    ///        }
    
    /// 自动重试异步代码，异步代码必须有`throws`事件
    /// - Parameters:
    ///   - priority: 优先级
    ///   - maxRetryCount: 最大重试次数
    ///   - operation: 要执行的操作
    ///   - retryDelay: 重试延迟
    /// - Returns: 任务完成之后返回要执行的结果
    @discardableResult
    public static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1,
        retryPredicate: RetryPredicateBool? = nil,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task<Success, Failure> {
        Task(priority: priority) {
            //重试条件，默认重试
            var retryBool = true
            var retryError: Error?
            
            for index in 0..<maxRetryCount {
                do {
//                    print("task-重试次数：\(index)")
                    return try await operation()
                } catch {
                    let oneSecond = TimeInterval(1_000_000_000)
                    let delay = UInt64(oneSecond * retryDelay)
                    try await Task<Never, Never>.sleep(nanoseconds: delay)
                    
                    retryError = error
                    
                    if let _retryR = retryPredicate {
                        retryBool = _retryR(error)
//                        print("task-错误信息：\(error),\(error.localizedDescription)")
//                        print("task-是否可以再次请求:\(retryBool)")
                        if retryBool == true { continue } 
                        else { break }
                    } else {
                        continue
                    }
                }
            }

            if retryBool == true {
                try Task<Never, Never>.checkCancellation()
                return try await operation()
            } else {
                guard let retryError else {
                    fatalError("重试有条件，error必须有值")
                }
                throw retryError
            }

//优先执行`for-in`异步函数，如果都失败了，会执行此语句。当api失败时，会进行n+1次请求
//            try Task<Never, Never>.checkCancellation()
//            return try await operation()
        }
    }
}
