//
//  CertStoreLoadAndSave_Tests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertStore_LoadAndSaveTests: XCTestCase {
    // MARK: Initiate Helpers
    var config: CertStoreConfig!
    var certStore: CertStore!
    
    var cryptoProvider: CryptoProviderTests!
    var secureDataStore: SecureDataStoreTests!
    var remoteDataProvider: RemoteDataProviderTests!
    
    let responseGenerator = ResponseGeneratorTests()
    
    // MARK: CertStore Preparation
    func prepareStore(with config: CertStoreConfig) {
        self.config = config
        cryptoProvider = CryptoProviderTests()
        secureDataStore = SecureDataStoreTests()
        remoteDataProvider = RemoteDataProviderTests()
        
        certStore = CertStore(configuration: config, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
    }
    
    // MARK: [CERTSTORE_LOAD_SAVE] Unit Tests
    func test_loadSave() {
        // MARK: F04-1
        prepareStore(with: .testConfig)
        
        // INITIATE STORE
        // DUPLICATE ENTRY TO TEST FILTERING
        remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry()
            .append(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
            .append(commonName: .testCommonName_2, fingerprint: .testFingerprint_2)
            .append(commonName: .testCommonName_1, fingerprint: .testFingerprint_Fallback)
            .duplicateThenAppendLast()
            .data()
        
        // fetch fingerprints from remote
        let updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        // Update succeed
        XCTAssertTrue(updateResult.value == .ok)
        // Initial load data
        XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
        // Save data after update
        XCTAssertTrue(secureDataStore.interceptor.called_save == 1)
        // No removal of data
        XCTAssertTrue(secureDataStore.interceptor.called_removeData == 0)
        
        
        guard let cache = secureDataStore.retrieveCacheData(forKey: certStore.instanceID) else {
            XCTFail("No data found in persistent storage")
            return
        }
        // Since duplicate entries will be filtered, there should only be 3 entries
        XCTAssertEqual(cache.certificates.count, 3)
        
        // MARK: SORT CERTIFICATE TEST
        XCTAssertEqual(cache.certificates[0].commonName, .testCommonName_1)
        XCTAssertEqual(cache.certificates[0].fingerprint, .testFingerprint_Fallback)
        XCTAssertEqual(cache.certificates[1].commonName, .testCommonName_1)
        XCTAssertEqual(cache.certificates[1].fingerprint, .testFingerprint_1)
        XCTAssertEqual(cache.certificates[2].commonName, .testCommonName_2)
        XCTAssertEqual(cache.certificates[2].fingerprint, .testFingerprint_2)
        
        // MARK: DATA DESERIALIZATION TEST
        certStore = CertStore(configuration: .testConfig, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
        secureDataStore.interceptor = .clean
        
        // Validate certificates in list
        var validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
        XCTAssertTrue(validationResult == .trusted)
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_Fallback)
        XCTAssertTrue(validationResult == .trusted)
        validationResult = certStore.validate(commonName: .testCommonName_2, fingerprint: .testFingerprint_2)
        XCTAssertTrue(validationResult == .trusted)
        
        // Check interceptor
        // Load +1 because of initial deserialization
        XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
        XCTAssertTrue(secureDataStore.interceptor.called_save == 0)
        XCTAssertTrue(secureDataStore.interceptor.called_removeData == 0)
    }
    
    func test_reset() {
        // MARK: F04-1
        prepareStore(with: .testConfig)
        
        remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry()
            .append(commonName: .testCommonName_1, expirationDate: .valid, fingerprint: .testFingerprint_Fallback)
            .append(commonName: .testCommonName_2, expirationDate: .never, fingerprint: .testFingerprint_2)
            .append(commonName: .testCommonName_1, expirationDate: .never, fingerprint: .testFingerprint_1)
            .data()
        
        var updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        XCTAssertTrue(updateResult.value == .ok)
        XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
        XCTAssertTrue(secureDataStore.interceptor.called_save == 1)
        XCTAssertTrue(secureDataStore.interceptor.called_removeData == 0)
        
        // Retrieve data from cache
        guard let cache = secureDataStore.retrieveCacheData(forKey: certStore.instanceID) else {
            XCTFail("No data found in persistent storage")
            return
        }
        // There should be 3 entries in the cache
        XCTAssertEqual(cache.certificates.count, 3)
        
        // Validate the entries
        var validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_Fallback)
        XCTAssertTrue(validationResult == .trusted)
        validationResult = certStore.validate(commonName: .testCommonName_2, fingerprint: .testFingerprint_2)
        XCTAssertTrue(validationResult == .trusted)
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
        XCTAssertTrue(validationResult == .trusted)
        
        // Clean secure data store interceptor before reset persistent storage
        secureDataStore.interceptor = .clean
        certStore.resetData()
        
        // Validation should return "EMPTY" since there is no data there
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_Fallback)
        XCTAssertTrue(validationResult == .empty)
        validationResult = certStore.validate(commonName: .testCommonName_2, fingerprint: .testFingerprint_2)
        XCTAssertTrue(validationResult == .empty)
        
        // Since there is no load and save data after reset, only removeData interceptor that been called
        XCTAssertTrue(secureDataStore.interceptor.called_loadData == 0)
        XCTAssertTrue(secureDataStore.interceptor.called_save == 0)
        XCTAssertTrue(secureDataStore.interceptor.called_removeData == 1)
        
        
        // Recover the persistent storage by retrieving data from remote server
        secureDataStore.interceptor = .clean
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        // Check the interceptor
        XCTAssertTrue(updateResult.value == .ok)
        XCTAssertTrue(secureDataStore.interceptor.called_loadData == 0)
        XCTAssertTrue(secureDataStore.interceptor.called_save == 1)
        XCTAssertTrue(secureDataStore.interceptor.called_removeData == 0)
        
        // Validate the entries
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_Fallback)
        XCTAssertTrue(validationResult == .trusted)
        validationResult = certStore.validate(commonName: .testCommonName_2, fingerprint: .testFingerprint_2)
        XCTAssertTrue(validationResult == .trusted)
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
        XCTAssertTrue(validationResult == .trusted)
    }
    
    func test_clearData() {
        // MARK: F04-1
        prepareStore(with: .testConfig)
        
        remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry()
            .data()
        
        let updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        // Clean secure data store interceptor before reset persistent storage
        secureDataStore.interceptor = .clean
        certStore.resetData()
        
        XCTAssertTrue(updateResult.value == .emptyStore)
        // Since there is no load and save data after reset, only removeData interceptor that been called
        XCTAssertTrue(secureDataStore.interceptor.called_loadData == 0)
        XCTAssertTrue(secureDataStore.interceptor.called_save == 0)
        XCTAssertTrue(secureDataStore.interceptor.called_removeData == 1)
    }
}
