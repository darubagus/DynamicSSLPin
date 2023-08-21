//
//  NetworkTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertStore_NetworkTests: XCTestCase {
    static let serviceURL = URL(string: "https://my-json-server.typicode.com/darubagus/fingerprints-api/db")
    static let publicKey = "BMFqh/CMj+9DhcagewoP7JkhRJyYvqgWkdDKV9cifHCfkRmu4oIwkCWDF7g3h0mBCukUocbNzXQ4fc4g4wr21xo="
    
    // MARK: Initiate Helpers
    var config: CertStoreConfig!
    var certStore: CertStore!
    
    var cryptoProvider: CryptoProvider!
    var secureDataStore: SecureDataStore!
    var remoteDataProvider: RemoteDataProvider!
    
    let responseGenerator = ResponseGeneratorTests()
    
    // MARK: CertStore Preparation
    func prepareStore() {
        self.config = CertStoreConfig(serviceURL: CertStore_NetworkTests.serviceURL!, pubKey: CertStore_NetworkTests.publicKey)
        cryptoProvider = CryptoKitCryptoProvider()
        secureDataStore = SecureDataStoreTests()
        remoteDataProvider = NetworkManager(baseURL: config.serviceURL, sslValidationStrat: .default)
        
        certStore = CertStore(configuration: config, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
    }
    
    func prepareEmptyStore(with config: CertStoreConfig) {
        self.config = config
        cryptoProvider = CryptoKitCryptoProvider()
        secureDataStore = SecureDataStoreTests()
        remoteDataProvider = RemoteDataProviderTests()
        
        certStore = CertStore(configuration: config, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
    }
    
    func test_realConnection_Valid() {
        // MARK: F05-1
        prepareStore()
        
        let updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        XCTAssertTrue(updateResult.value == .ok)
        
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
