//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation

@available(iOS 13.0, *)
public class SSLPinningValidationStrategy: NSObject {
    public let certStore: CertStore
    
    public init(certStore: CertStore) {
        self.certStore = certStore
    }
    
    public func sslValidation(for session: URLSession, challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }
}
