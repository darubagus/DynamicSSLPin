//
//  Integrator.swift
//  
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation


@available(iOS 16.0, *)
public extension CertStore {
    func sslValidationStrategy() -> NSObject {
        return SSLPinningValidationStrat(certStore: self)
    }
    
    static func integrateCertStore(configuration: CertStoreConfig) -> CertStore {
        return CertStore(configuration: configuration, cryptoProvider: CryptoKitCryptoProvider(), secureDataStore: SecureDataProvider())
    }
}
