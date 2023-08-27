//
//  CertStore.swift
//  
//
//  Created by Daru Bagus Dananjaya on 07/06/23.
//

import Foundation
import os

@available(iOS 13.0, *)
public class CertStore {
    
    public var instanceID: String {
        return configuration.identifier ?? "default"
    }
    
    public let configuration: CertStoreConfig
    
    let cryptoProvider: CryptoProvider
    let secureDataStore: SecureDataStore
    let remoteDataProvider: RemoteDataProvider
    
    // Logger
    public let logger = Logger(subsystem: "com.darubagus.DynamicSSLPin-TA", category: "CertStore")
    
    // semaphore with initial value of 1 to control access across multiple exec
    fileprivate let semaphore = DispatchSemaphore(value: 1)
    
    fileprivate var isCacheLoaded: Bool = false
    fileprivate var cachedData: CacheData?
    fileprivate var certInfo = [CertInfo]()
    
    internal init(configuration: CertStoreConfig, cryptoProvider: CryptoProvider, secureDataStore: SecureDataStore, remoteDataProvider: RemoteDataProvider) {
        configuration.validate(crypto: cryptoProvider)
        self.configuration = configuration
        self.cryptoProvider = cryptoProvider
        self.secureDataStore = secureDataStore
        self.remoteDataProvider = remoteDataProvider
    }
    
    public init(configuration: CertStoreConfig, cryptoProvider: CryptoProvider, secureDataStore: SecureDataStore) {
        configuration.validate(crypto: cryptoProvider)
        self.configuration = configuration
        self.cryptoProvider = cryptoProvider
        self.secureDataStore = secureDataStore
        self.remoteDataProvider = NetworkManager(baseURL: configuration.serviceURL, sslValidationStrat: configuration.validationStrategy)
    }
    
    // remove all cached certificate data from memory
    // FOR TESTING PURPOSE ONLY
    public func resetData() {
        
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        
        cachedData = nil
        secureDataStore.removeData(forKey: self.instanceID)
        logger.log("[RESET] Reset cache triggered")
    }
}

@available(iOS 13.0, *)
internal extension CertStore {
    
    private func loadCache() {
        if !isCacheLoaded {
            cachedData = loadCachedData()
            certInfo = loadFallbackCertificates()
            isCacheLoaded = true
        }
    }

    func getAllCertificate() -> [CertInfo] {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        
        loadCache()
        
        var certificates = cachedData?.certificates ?? []
        certificates.append(contentsOf: certInfo)
        
        return certificates
    }
    
    func getCachedData() -> CacheData? {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        
        loadCache()
        
        return cachedData
    }
    
    func updateCachedData(closure: (CacheData?) -> CacheData?) -> Void {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        
        loadCache()
        
        if let newData = closure(cachedData) {
            cachedData = newData
            saveData(data: newData)
        }
    }
}
