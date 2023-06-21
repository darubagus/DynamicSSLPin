//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 07/06/23.
//

import Foundation

public struct CertStoreConfig {
    
// PROPERTIES
    public let serviceURL: URL
    
    public let pubKey: String
    
    public let useChallenge: Bool
    
//    optional
    public let identifier: String?
    
//    optional
    public let expectedCommonNames: [String]?
    
//   optional
    public let fallbackCertificate: Data?
    
/**
    Interval Config
 */
    public let updateInterval: TimeInterval
    
    public let expirationThreshold: TimeInterval
    
    public let validationStrategy: SSLValidationStrat
    
//    CONSTRUCTOR
    /**
            default value:
            update Interval: once every week
            Expiration threshold: once every two week
     */
    public init(serviceURL: URL, pubKey: String, useChallenge: Bool, identifier: String?, expectedCommonNames: [String]?, fallbackCertificate: Data?, updateInterval: TimeInterval = 7*24*60*60, expirationThreshold: TimeInterval = 14*24*60*60, validationStrategy: SSLValidationStrat) {
        self.serviceURL = serviceURL
        self.pubKey = pubKey
        self.useChallenge = useChallenge
        self.identifier = identifier
        self.expectedCommonNames = expectedCommonNames
        self.fallbackCertificate = fallbackCertificate
        self.updateInterval = updateInterval
        self.expirationThreshold = expirationThreshold
        self.validationStrategy = validationStrategy
    }
}

@available(iOS 13.0, *)
extension CertStoreConfig {
    public func validate(crypto: CryptoProvider) {
        
        if serviceURL.absoluteString.hasPrefix("http:") {
            print(" '.serviceURL' should point to 'https' endpoint.")
        }
        
        if validationStrategy == .noValidation {
            print(" .SSLValidationStrat.noValidation should not be used in production env")
        }

        if let fallbackCertData = fallbackCertificate {
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .base64
            decoder.dateDecodingStrategy = .secondsSince1970
            
            if let fallback = try? decoder.decode(Fingerprint.self, from: fallbackCertData) {
                for entry in fallback.fingerprints {
                    if let expectedCommonNameValidation = expectedCommonNames {
                        if !expectedCommonNameValidation.contains(entry.name) {
                            print("CertStore: certificate '\(entry.name)' in '.fallbackCertData' is issued for common name, which is not included in 'expectedCommonNames'.")
                        }
                    }
                    
                    // check if cert is already expired
                    if entry.expirationDate.timeIntervalSinceNow < 0 {
                        print("CertStore: certificate '\(entry.name)' in '.fallbackCertData' is already expired.")
                    }
                }
            } else {
                print("CertStore: '.fallbackCertData' contains invalid JSON.")
            }
        }
        
        // validate EC Public Key
        _ = crypto.importECPubblicKey(pubKeyBase64: pubKey)
        // Handle negative time interval
        if expirationThreshold < 0 || updateInterval < 0 {
            debug.fatalError("Invalid TimeInterval: Expiration Treshold or updateInterval")
        }
    }
}


