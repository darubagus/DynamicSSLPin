//
//  SessionDelegateTests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

class SessionDelegateTests: NSObject, URLSessionDelegate {
    
    // MARK: Interceptor
    struct Interceptor {
        var called_didReceiveChallenge = 0
        
        static var clean: Interceptor { return Interceptor() }
    }
    
    var interceptor = Interceptor()
    
    // MARK: Variable
    var onChallenge: (_ challenge: URLAuthenticationChallenge, _ completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
    
    // MARK: Constructor
    init(onChallenge: @escaping (_ challenge: URLAuthenticationChallenge, _ completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void) {
        self.onChallenge = onChallenge
    }
    
    // MARK: Method
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.interceptor.called_didReceiveChallenge += 1
        self.onChallenge(challenge, completionHandler)
    }
}
