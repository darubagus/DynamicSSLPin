//
//  Constants.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

// MARK: Constants Used in Tests
extension String {
    
    static let testCommonName_1             = "testcommonName1.org"
    static let testCommonName_2             = "testcommonName2.org"
    
    static let testCommonName_Unknown       = "www.gulugulu.com"
    static let testCommonName_Fallback      = "fallbackAPI.id"
}

extension Data {
    
    static let testFingerprint_1            = Data(repeating: 0x01, count: 32)
    static let testFingerprint_2            = Data(repeating: 0x02, count: 32)

    static let testFingerprint_Unknown      = Data(repeating: 0xC3, count: 32)  // Use for completely unknown fingerprints
    static let testFingerprint_Fallback     = Data(repeating: 0xFF, count: 32)  // Use for fallback cert
}

extension TimeInterval {
    
    // Allows detection whether silent update has been scheduled on background
    static let testLatency_ForSilentUpdate: TimeInterval            = 1.0
    static let testLatency_ForFastUpdate: TimeInterval              = 0.5       // We need to count with polling loops, it's in fact very quick
    
    static let testUpdateInterval_ExpirationThreshold: TimeInterval = 10.0      // --> cfg.expirationUpdateTreshold
    static let testUpdateInterval_PeriodicUpdate: TimeInterval      = 5.0       // --> cfg.periodicUpdateInterval
    
    // Intervals for "Expiration" enum
    static let testExpiration_Soon: TimeInterval  = 30.0
    static let testExpiration_Valid: TimeInterval = 60.0
    static let testExpiration_Never: TimeInterval = 365*24*60*60
}
