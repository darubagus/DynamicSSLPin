//
//  CertStoreConfig_Tests.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation
@testable import DynamicSSLPin_TA

extension CertStoreConfig {
    static var testConfig: CertStoreConfig {
        return CertStoreConfig(
            serviceURL: URL(string: "https://my-json-server.typicode.com/darubagus/fingerprints-api/db")!,
            pubKey: "BMFqh/CMj+9DhcagewoP7JkhRJyYvqgWkdDKV9cifHCfkRmu4oIwkCWDF7g3h0mBCukUocbNzXQ4fc4g4wr21xo=",
            identifier: nil,
            fallbackCertificate: nil,
            updateInterval: .testUpdateInterval_PeriodicUpdate,
            expirationThreshold: .testUpdateInterval_ExpirationThreshold)
    }
    
    static func testConfigWithFallbackCertificate(expirationDate: Expiration) -> CertStoreConfig {
        let fallbackData = Fingerprint.single(commonName: .testCommonName_Fallback, expiration: expirationDate, fingerprint: .testFingerprint_Fallback).toJSON()
        return CertStoreConfig(
            serviceURL: URL(string: "https://my-json-server.typicode.com/darubagus/fingerprints-api/db")!,
            pubKey: "BMFqh/CMj+9DhcagewoP7JkhRJyYvqgWkdDKV9cifHCfkRmu4oIwkCWDF7g3h0mBCukUocbNzXQ4fc4g4wr21xo=",
            identifier: nil,
            fallbackCertificate: fallbackData,
            updateInterval: .testUpdateInterval_PeriodicUpdate,
            expirationThreshold: .testUpdateInterval_ExpirationThreshold
        )
    }
    
    static func testConfigWithExpectedCommonNames(_ commonNames: [String]) -> CertStoreConfig {
        return CertStoreConfig(
            serviceURL: URL(string: "https://my-json-server.typicode.com/darubagus/fingerprints-api/db")!,
            pubKey: "BMFqh/CMj+9DhcagewoP7JkhRJyYvqgWkdDKV9cifHCfkRmu4oIwkCWDF7g3h0mBCukUocbNzXQ4fc4g4wr21xo=",
            identifier: nil,
            expectedCommonNames: commonNames,
            fallbackCertificate: nil,
            updateInterval: .testUpdateInterval_PeriodicUpdate,
            expirationThreshold: .testUpdateInterval_ExpirationThreshold)
    }
}


