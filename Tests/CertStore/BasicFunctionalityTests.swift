//
//  CertStoreBasic_Tests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 13/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertStore_BasicFunctionalityTests: XCTestCase {
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
    
    func allConfiguration() -> [(config: CertStoreConfig, name: String, hasFallback: Bool, expiredFallback: Bool)] {
        return[
            (.testConfig, "W/O fallback" , false, false),
            (.testConfigWithFallbackCertificate(expirationDate: .valid), "Valid fallback certificate", true, false),
            (.testConfigWithFallbackCertificate(expirationDate: .expired), "Expired fallback certificate", true, true)
        ]
    }
    
    // MARK: [CERTSTORE_BASIC] Unit Tests
    func test_EmptyStore_UpdateNoRemoteData() {
        allConfiguration().forEach { (configuration) in
            
            var updateResult: Result<UpdateResult, Error>
            
            prepareStore(with: configuration.config)
            
            remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry().data()
            
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            
            XCTAssertTrue(updateResult.value == .emptyStore)
            // 1 Import during config + 1 Import during process received data
            XCTAssertTrue(cryptoProvider.interceptor.called_importECPublicKey == 2)
            // 1 Load data
            XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
            // 1 fetch fingerprints method
            XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
            
            // TRY TO UPDATE AGAIN
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .emptyStore)
            // +1 import during update
            XCTAssertTrue(cryptoProvider.interceptor.called_importECPublicKey == 3)
            // don't load any data since the last load
            XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
            // +1 fetch fingerprints method
            XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 2)
        }
    }
    
    func test_EmptyStore_withValidation() {
        allConfiguration().forEach { (configuration) in
            
            var validationResult: ValidationResult
            
            prepareStore(with: configuration.config)
            
            remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry().data()
            
            // EMPTY STORE
            validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
            XCTAssertTrue(validationResult == .empty)
            // Initial import at config
            XCTAssertTrue(cryptoProvider.interceptor.called_importECPublicKey == 1)
            // Initial load data from persistent storage
            XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
            // No access yet to remote data
            XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 0)
            
            
            validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_Unknown)
            XCTAssertTrue(validationResult == .empty)
            // Initial import at config
            XCTAssertTrue(cryptoProvider.interceptor.called_importECPublicKey == 1)
            // No additional load since the last load
            XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
            // Still no access to remote data
            XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 0)
            
            validationResult = certStore.validate(commonName: .testCommonName_Fallback, fingerprint: .testFingerprint_Fallback)
            var expectedCN: ValidationResult = configuration.hasFallback ? (configuration.expiredFallback ? .empty : .trusted) : .empty
            XCTAssertTrue(validationResult == expectedCN)
            // Initial import at config
            XCTAssertTrue(cryptoProvider.interceptor.called_importECPublicKey == 1)
            // No additional load since the last load
            XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
            // Still no access to remote data
            XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 0)
            
            validationResult = certStore.validate(commonName: .testCommonName_Fallback, fingerprint: .testFingerprint_Unknown)
            expectedCN = configuration.hasFallback ? (configuration.expiredFallback ? .empty : .untrusted) : .empty
            XCTAssertTrue(validationResult == expectedCN)
            // Initial import at config
            XCTAssertTrue(cryptoProvider.interceptor.called_importECPublicKey == 1)
            // No additional load since the last load
            XCTAssertTrue(secureDataStore.interceptor.called_loadData == 1)
            // Still no access to remote data
            XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 0)
        }
    }
    
    func test_EmptyStore_updateToAlreadyExpiredFingerprint() {
        allConfiguration().forEach { (configuration) in
            var updateResult: Result<UpdateResult, Error>
            var validationResult: ValidationResult
            
            prepareStore(with: configuration.config)
            
            remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry().append(commonName: .testCommonName_1, expirationDate: .expired, fingerprint: .testFingerprint_1).data()
            
            validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
            XCTAssertTrue(validationResult == .empty)
            
            updateResult = AsyncHelper.wait { (completion) in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            
            // MARK: TRY TO IMPORT EXPIRED CERT, STORE WILL STILL BE EMPTY
            XCTAssertTrue(updateResult.value == .emptyStore)
            validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
            XCTAssertTrue(validationResult == .empty)
            
            // MARK: VALIDATION AGAINST UNKNOWN CN
            validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_Unknown)
            XCTAssertTrue(validationResult == .empty)
            validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_1)
            XCTAssertTrue(validationResult == .empty)
            validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_Fallback)
            XCTAssertTrue(validationResult == .empty)
            
            // MARK: VALIDATION AGAINST FALLBACK CERTIFICATES
            validationResult = certStore.validate(commonName: .testCommonName_Fallback, fingerprint: .testFingerprint_Fallback)
            var expectedCN: ValidationResult = configuration.hasFallback ? (configuration.expiredFallback ? .empty : .trusted) : .empty
            XCTAssertTrue(validationResult == expectedCN)
            validationResult = certStore.validate(commonName: .testCommonName_Fallback, fingerprint: .testFingerprint_Unknown)
            expectedCN = configuration.hasFallback ? (configuration.expiredFallback ? .empty : .untrusted) : .empty
            XCTAssertTrue(validationResult == expectedCN)
        }
    }
    
    func test_EmptyStore_updateToValidData() {
        allConfiguration().forEach { (configuration) in
            
            prepareStore(with: configuration.config)
            
            remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry().append(commonName: .testCommonName_1, expirationDate: .valid, fingerprint: .testFingerprint_1).data()
            
            var validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
            XCTAssertTrue(validationResult == .empty)
            
            let updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .ok)
            
            // MARK: FINGERPRINT IN STORE, VALIDATION WILL PASS
            validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
            XCTAssertTrue(validationResult == .trusted)
            validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_Unknown)
            XCTAssertTrue(validationResult == .untrusted)
            
            // MARK: VALIDATION AGAINST UNKNOWN CN
            validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_Unknown)
            XCTAssertTrue(validationResult == .empty)
            validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_Fallback)
            XCTAssertTrue(validationResult == .empty)
            validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_1)
            XCTAssertTrue(validationResult == .empty)
            
            // MARK: VALIDATION AGAINST FALLBACK CERTIFICATES
            validationResult = certStore.validate(commonName: .testCommonName_Fallback, fingerprint: .testFingerprint_Fallback)
            var expectedCN: ValidationResult = configuration.hasFallback ? (configuration.expiredFallback ? .empty : .trusted) : .empty
            XCTAssertTrue(validationResult == expectedCN)
            validationResult = certStore.validate(commonName: .testCommonName_Fallback, fingerprint: .testFingerprint_Unknown)
            expectedCN = configuration.hasFallback ? (configuration.expiredFallback ? .empty : .untrusted) : .empty
            XCTAssertTrue(validationResult == expectedCN)
        }
    }
    
    func test_EmptyStore_failedUpdate() {
        allConfiguration().forEach { configuration in
            var updateResult: Result<UpdateResult, Error>
            var reportedError: Error? = nil
            
            prepareStore(with: configuration.config)
            
            // MARK: NETWORK ERROR HANDLING
            
            remoteDataProvider.setNoLatency().setReportError(true)
            
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    reportedError = error
                    completion.complete(with: result)
                }
            }
            
            XCTAssertTrue(updateResult.value == .networkError)
            XCTAssertNotNil(reportedError)
            
            // MARK: INVALID SIGNATURE HANDLING
            
            remoteDataProvider.setNoLatency().setReportError(false).reportData = responseGenerator.removeAllEntry().append(commonName: .testCommonName_1, expirationDate: .valid, fingerprint: .testFingerprint_1).data()
            
            cryptoProvider.failure_onECDSAValidation = true
            
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    reportedError = error
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .invalidSignature)
            XCTAssertNil(reportedError)
            
            // MARK: INVALID DATA HANDLING
            
            remoteDataProvider.setNoLatency().setReportError(false).reportData = "UNEXPECTED SERVER ERROR".data(using: .ascii)
            
            cryptoProvider.failure_onECDSAValidation = false
            
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    reportedError = error
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .invalidData)
            XCTAssertNil(reportedError)
        }
    }
}
