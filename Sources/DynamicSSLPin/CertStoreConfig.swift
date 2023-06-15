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
    public let UpdateInterval: TimeInterval
    
    public let expirationThreshold: TimeInterval
    
    public let validationStrategy: SSLValidationStrat
    
//    CONSTRUCTOR
    public init(serviceURL: URL, pubKey: String, useChallenge: Bool, identifier: String?, expectedCommonNames: [String]?, fallbackCertificate: Data?, UpdateInterval: TimeInterval, expirationThreshold: TimeInterval, validationStrategy: SSLValidationStrat) {
        self.serviceURL = serviceURL
        self.pubKey = pubKey
        self.useChallenge = useChallenge
        self.identifier = identifier
        self.expectedCommonNames = expectedCommonNames
        self.fallbackCertificate = fallbackCertificate
        self.UpdateInterval = UpdateInterval
        self.expirationThreshold = expirationThreshold
        self.validationStrategy = validationStrategy
    }
}

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
        
        // Handle negative time interval
    }
}


