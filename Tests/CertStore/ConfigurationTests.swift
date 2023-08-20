//
//  ConfigurationTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 20/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertStore_ConfigurationTests: XCTestCase {
    func test_CertStoreConfig_validURL_validPubKey() {
        var config: CertStoreConfig!
        var certStore: CertStore!
        
        var cryptoProvider: CryptoProviderTests! = CryptoProviderTests()
        var secureDataStore: SecureDataStoreTests! = SecureDataStoreTests()
        var remoteDataProvider: RemoteDataProviderTests! = RemoteDataProviderTests()
        
        let responseGenerator = ResponseGeneratorTests()
        
        config = CertStoreConfig(serviceURL: URL(string: .validUrlString)!, pubKey: "BMFqh/CMj+9DhcagewoP7JkhRJyYvqgWkdDKV9cifHCfkRmu4oIwkCWDF7g3h0mBCukUocbNzXQ4fc4g4wr21xo=")
        
        certStore = CertStore(configuration: config, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
        XCTAssertNotNil(certStore)
    }
}
