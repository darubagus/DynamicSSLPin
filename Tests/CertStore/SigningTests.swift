//
//  SigningTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertStore_SigningTests: XCTestCase {
    // MARK: Initiate Helpers
    var config: CertStoreConfig!
    var certStore: CertStore!
    
    var cryptoProvider: CryptoProviderTests!
    var secureDataStore: SecureDataStoreTests!
    var remoteDataProvider: RemoteDataProviderTests!
    
    let keypair = ECDSA.generateKeyPair()
    let responseGenerator = ResponseGeneratorTests()
    
    // MARK: CertStore Preparation
    func prepareStore(with config: CertStoreConfig) {
        self.config = config
        cryptoProvider = CryptoProviderTests()
        secureDataStore = SecureDataStoreTests()
        remoteDataProvider = RemoteDataProviderTests()
        
        certStore = CertStore(configuration: config, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
    }
    
    // MARK: [CERTSTORE_SIGNING] Unit Tests
    func test_Signing() {
        prepareStore(with: .testConfig)
        
        remoteDataProvider.reportData = responseGenerator.signEntry(with: keypair.privateKey).append(commonName: .testCommonName_1, expirationDate: .never, fingerprint: .testFingerprint_1).append(commonName: .testCommonName_2, expirationDate: .never, fingerprint: .testFingerprint_2).data()
        
        let updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        XCTAssertTrue(updateResult.value == .ok)
        
        var validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
        XCTAssertTrue(validationResult == .trusted)
        validationResult = certStore.validate(commonName: .testCommonName_2, fingerprint: .testFingerprint_2)
        XCTAssertTrue(validationResult == .trusted)
    }
}
