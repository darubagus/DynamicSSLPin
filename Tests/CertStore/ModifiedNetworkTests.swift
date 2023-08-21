//
//  ModifiedNetworkTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 20/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertStore_ModifiedNetworkTests: XCTestCase {
    // MARK: Initiate Helpers
    var config: CertStoreConfig!
    var certStore: CertStore!
    
    var cryptoProvider: CryptoProviderTests!
    var secureDataStore: SecureDataStoreTests!
    var remoteDataProvider: RemoteDataProviderTests!
    
    let responseGenerator = ResponseGeneratorTests()
    
    func prepareStore(with config: CertStoreConfig) {
        self.config = config
        cryptoProvider = CryptoProviderTests()
        secureDataStore = SecureDataStoreTests()
        remoteDataProvider = RemoteDataProviderTests()
        
        certStore = CertStore(configuration: config, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
    }
    
    func test_realConnection_InvalidCertificate() {
        // MARK: F05-2
        var updateResult: Result<UpdateResult, Error>
        var validationResult: ValidationResult
        
        prepareStore(with: .testConfig)

        remoteDataProvider.setNoLatency().reportData = responseGenerator
            .removeAllEntry()
            .append(commonName: .testCommonName_Unknown, expirationDate: .valid, fingerprint: .testFingerprint_Unknown)
            .data()
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        XCTAssertTrue(updateResult.value == .ok)
        validationResult = certStore.validate(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_Unknown)
        XCTAssertTrue(validationResult == .trusted)
        
        let sessionDelegate = SessionDelegateTests { (challenge, callback) in
            let validationResult = self.certStore.validate(challenge: challenge)
            switch validationResult {
            case .trusted:
                callback(.performDefaultHandling, nil)
            case .untrusted, .empty:
                callback(.cancelAuthenticationChallenge, nil)
            }
            XCTAssertTrue(validationResult == .empty)
        }
        
        let urlSession = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        let result: Data? = RemoteDataObject(session: urlSession, request: URLRequest(url: URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=-6.2944&lon=106.7857&appid=cc3f0108e08711cb126c71d1c83a8aaf")!)).get()
        XCTAssertNil(result)
        XCTAssertTrue(sessionDelegate.interceptor.called_didReceiveChallenge == 1)
    }
    
    func test_realConnection_ExpiredCertificate() {
        // MARK: F05-3
        var updateResult: Result<UpdateResult, Error>
        var validationResult: ValidationResult
        
        prepareStore(with: .testConfig)

        remoteDataProvider.setNoLatency().reportData = responseGenerator
            .removeAllEntry()
            .append(commonName: .networkCommonName, expirationDate: .verySoon, fingerprint: .validFingerprint)
            .data()
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        XCTAssertTrue(updateResult.value == .ok)
        validationResult = certStore.validate(commonName: .networkCommonName, fingerprint: .validFingerprint ?? .testFingerprint_Fallback)
        XCTAssertTrue(validationResult == .trusted)
        
        // Wait for 8 seconds until the certificate is expired
        Thread.waitFor(interval: 5.0)
        
        let sessionDelegate = SessionDelegateTests { (challenge, callback) in
            let validationResult = self.certStore.validate(challenge: challenge)
            switch validationResult {
            case .trusted:
                callback(.performDefaultHandling, nil)
            case .untrusted, .empty:
                callback(.cancelAuthenticationChallenge, nil)
            }
            Debug.message("\(validationResult)")
            XCTAssertTrue(validationResult == .empty)
        }
        
        let urlSession = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        let result: Data? = RemoteDataObject(session: urlSession, request: URLRequest(url: URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=-6.2944&lon=106.7857&appid=cc3f0108e08711cb126c71d1c83a8aaf")!)).get()
        XCTAssertNil(result)
        XCTAssertTrue(sessionDelegate.interceptor.called_didReceiveChallenge == 1)
    }
    
    func test_realConnection_EmptyStore() {
        // MARK: F05-4
        prepareStore(with: .testConfig)
        
        remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry().data()
        
        let updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        XCTAssertTrue(updateResult.value == .emptyStore)
        
        let sessionDelegate = SessionDelegateTests { (challenge, callback) in
            let validationResult = self.certStore.validate(challenge: challenge)
            switch validationResult {
            case .trusted:
                callback(.performDefaultHandling, nil)
            case .untrusted, .empty:
                callback(.cancelAuthenticationChallenge, nil)
            }
            XCTAssertTrue(validationResult == .empty)
        }
        
        let urlSession = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        let result: Data? = RemoteDataObject(session: urlSession, request: URLRequest(url: URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=-6.2944&lon=106.7857&appid=cc3f0108e08711cb126c71d1c83a8aaf")!)).get()
        XCTAssertNil(result)
        XCTAssertTrue(sessionDelegate.interceptor.called_didReceiveChallenge == 1)
    }
    
    func test_realConnection_EmptyExpectedCommonName() {
        // MARK: F05-5
        var updateResult: Result<UpdateResult, Error>
        var validationResult: ValidationResult
        
        prepareStore(with: .testConfigWithExpectedCommonNames([]))

        remoteDataProvider.setNoLatency().reportData = responseGenerator
            .removeAllEntry()
            .append(commonName: .networkCommonName, expirationDate: .valid, fingerprint: .validFingerprint)
            .data()
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        XCTAssertTrue(updateResult.value == .ok)
        validationResult = certStore.validate(commonName: .networkCommonName, fingerprint: .validFingerprint ?? .testFingerprint_Fallback)
        XCTAssertTrue(validationResult == .untrusted)
        
        let sessionDelegate = SessionDelegateTests { (challenge, callback) in
            let validationResult = self.certStore.validate(challenge: challenge)
            switch validationResult {
            case .trusted:
                callback(.performDefaultHandling, nil)
            case .untrusted, .empty:
                callback(.cancelAuthenticationChallenge, nil)
            }
            XCTAssertTrue(validationResult == .untrusted)
        }
        
        let urlSession = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        let result: Data? = RemoteDataObject(session: urlSession, request: URLRequest(url: URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=-6.2944&lon=106.7857&appid=cc3f0108e08711cb126c71d1c83a8aaf")!)).get()
        XCTAssertNil(result)
        XCTAssertTrue(sessionDelegate.interceptor.called_didReceiveChallenge == 1)
    }
    
    func test_realConnection_InvalidFingerprint() {
        // MARK: F05-6
        var updateResult: Result<UpdateResult, Error>
        var validationResult: ValidationResult
        
        prepareStore(with: .testConfigWithExpectedCommonNames([]))

        remoteDataProvider.setNoLatency().reportData = responseGenerator
            .removeAllEntry()
            .append(commonName: .networkCommonName, expirationDate: .valid, fingerprint: .testFingerprint_Unknown)
            .data()
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        XCTAssertTrue(updateResult.value == .ok)
        validationResult = certStore.validate(commonName: .networkCommonName, fingerprint: .validFingerprint ?? .testFingerprint_Fallback)
        XCTAssertTrue(validationResult == .untrusted)
        
        let sessionDelegate = SessionDelegateTests { (challenge, callback) in
            let validationResult = self.certStore.validate(challenge: challenge)
            switch validationResult {
            case .trusted:
                callback(.performDefaultHandling, nil)
            case .untrusted, .empty:
                callback(.cancelAuthenticationChallenge, nil)
            }
            XCTAssertTrue(validationResult == .untrusted)
        }
        
        let urlSession = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        let result: Data? = RemoteDataObject(session: urlSession, request: URLRequest(url: URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=-6.2944&lon=106.7857&appid=cc3f0108e08711cb126c71d1c83a8aaf")!)).get()
        XCTAssertNil(result)
        XCTAssertTrue(sessionDelegate.interceptor.called_didReceiveChallenge == 1)
    }
    
    func test_realConnection_DuplicateFingerprint() {
        // MARK: AdditionalTests
        var updateResult: Result<UpdateResult, Error>
        var validationResult: ValidationResult
        
        prepareStore(with: .testConfigWithExpectedCommonNames(["*.openweathermap.org"]))

        remoteDataProvider.setNoLatency().reportData = responseGenerator
            .removeAllEntry()
            .append(commonName: .networkCommonName, expirationDate: .valid, fingerprint: .validFingerprint)
            .data()
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        XCTAssertTrue(updateResult.value == .ok)
        validationResult = certStore.validate(commonName: .networkCommonName, fingerprint: .validFingerprint ?? .testFingerprint_Fallback)
        Debug.message("\(validationResult)")
        XCTAssertTrue(validationResult == .trusted)
        
        remoteDataProvider.setNoLatency().reportData = responseGenerator
            .append(commonName: .networkCommonName, expirationDate: .valid, fingerprint: .validFingerprint)
            .data()
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        
        XCTAssertTrue(updateResult.value == .ok)
        validationResult = certStore.validate(commonName: .networkCommonName, fingerprint: .validFingerprint ?? .testFingerprint_Fallback)
        Debug.message("\(validationResult)")
        XCTAssertTrue(validationResult == .trusted)
        
        let sessionDelegate = SessionDelegateTests { (challenge, callback) in
            let validationResult = self.certStore.validate(challenge: challenge)
            switch validationResult {
            case .trusted:
                callback(.performDefaultHandling, nil)
            case .untrusted, .empty:
                callback(.cancelAuthenticationChallenge, nil)
            }
            XCTAssertTrue(validationResult == .trusted)
        }
        
        let urlSession = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        let result: Data? = RemoteDataObject(session: urlSession, request: URLRequest(url: URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=-6.2944&lon=106.7857&appid=cc3f0108e08711cb126c71d1c83a8aaf")!)).get()
        XCTAssertNotNil(result)
        XCTAssertTrue(sessionDelegate.interceptor.called_didReceiveChallenge == 1)
    }
}

