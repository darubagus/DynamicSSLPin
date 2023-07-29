//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation

@available(iOS 15.0, *)
public class SSLPinningValidationStrat: NSObject {
    public let certStore: CertStore
    
    public init(certStore: CertStore) {
        self.certStore = certStore
    }
    
    public func validateSSL(for session: URLSession, challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        switch certStore.validate(challenge: challenge) {
            case .trusted: completionHandler(.performDefaultHandling, nil)
            case .empty, .untrusted: completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
