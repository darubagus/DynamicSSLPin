//
//  Async.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation
import DynamicSSLPin_TA

class AsyncHelper<Success> {
    
    /// Creates a new instance of `AsyncHelper` internally and immediately executes the provided block.
    /// In the block, you can start any asynchronous operation with any completion, but once
    /// you exit the `block` closure, the execution ends in a waiting RunLoop. You have to call
    /// waiting.complete(with: result) to break the waiting loop. If you don't report
    /// the completion in predefined time (10 seconds), then the exception is thrown.
    ///
    /// The method returns the same result object as you previously passed to `complete(with:)` method.
    ///
    /// - Parameter waitTimeout: For how long helper will wait for asynchronous operation completion (in seconds)
    /// - Parameter block: Closure where you can implement your asynchronous operation start
    /// - Parameter completion: Object for signalling that asynchronous operation did finish
    ///
    /// - Returns: Object provided in `complete(with:)` method
    static func wait(waitTimeout: TimeInterval = 10, _ block: (_ completion: AsyncHelper) -> Void) -> Result<Success, Error> {
        let helper = AsyncHelper()
        block(helper)
        return helper.waitForCompletion(timeout: waitTimeout)
    }
    
    /// Reports success to a waiting object and breaks waiting loop. The result can be reported from
    /// an arbitrary thread.
    func complete(with result: Success) {
        self.result = .success(result)
        semaphore.signal()
    }
    
    /// Reports failure to a waiting object and breaks waiting loop. The error can be reported from
    /// an arbitrary thread.
    func complete(with error: Error) {
        self.result = .failure(error)
        semaphore.signal()
    }
    
    // MARK: - Private
    
    private let semaphore: DispatchSemaphore
    private var result: Result<Success, Error>?
    
    private init() {
        semaphore = DispatchSemaphore(value: 0)
    }
    
    /// Private function implements waiting for an asynchronous operation.
    private func waitForCompletion(timeout: TimeInterval) -> Result<Success, Error> {
        var attempts = Int(timeout * 4) // timeout / (0.125 + 0.125) => timeout * 4 => attempts
        var triggered = false
        while attempts > 0 && !triggered {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.125))    // 1st wait, 0.125s
            triggered = semaphore.wait(timeout: .now() + 0.125) == .success  // 2nd wait, 0.125s
            attempts -= 1
        }
        guard triggered else {
            return .failure(AsyncHelperError.timedOut)
        }
        guard let result = result else {
            return .failure(AsyncHelperError.resultNotProvided)
        }
        return result
    }
}

enum AsyncHelperError: Error {
    /// Waiting for asynchronous operation did time out. The default waiting time is 10 seconds.
    case timedOut
    /// The result object was not provided by the asynchronous operation.
    case resultNotProvided
}

extension Thread {
    
    /// Helper function just wait for given time interval. The run loop can process
    /// messages received during this period of time.
    static func waitFor(interval: TimeInterval, message: String = "") {
        Debug.message("Waiting for \(interval) seconds... \(message)")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: interval))
    }
    
    /// Helper function waits in run loop, until the closure is returning true.
    /// The loop is automatically
    static func waitUntil(closure: ()->Bool) throws {
        var safeCounter = 0
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.125))
            safeCounter += 1
            // Throw an exception after 30 seconds
            if safeCounter > 240 {
                throw AsyncHelperError.timedOut
            }
        } while closure()
    }
    
    /// Returns how much time elepased during the closure execution.
    static func measureElapsedTime(closure: ()->Void) -> TimeInterval {
        let start = Date()
        closure()
        return -start.timeIntervalSinceNow
    }
}
