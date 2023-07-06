//
//  Integrator.swift
//  
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation

@available(iOS 13.0, *)
public class SSLPinningValidationStrat: NSObject {
    public let certStore: CertStore
    
    public init(certStore: CertStore) {
        self.certStore = certStore
    }
    
    @available(iOS 15.0, *)
    public func validateSSL(for session: URLSession, challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        switch certStore.validate(challenge: challenge) {
            case .trusted: completionHandler(.performDefaultHandling, nil)
            case .empty, .untrusted: completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

@available(iOS 13.0, *)
public extension CertStore {
    func sslValidationStraategy() -> NSObject {
        return SSLPinningValidationStrat(certStore: self)
    }
    
    static func integrateCertStore(configuration: CertStoreConfig) -> CertStore {
        return CertStore(configuration: configuration, cryptoProvider: CryptoKitCryptoProvider(), secureDataStore: SecureDataProvider())
    }
}
