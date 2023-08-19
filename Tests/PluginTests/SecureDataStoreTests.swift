//
//  SecureDataStoreTests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

@testable import DynamicSSLPin

class SecureDataStoreTests: SecureDataStore {
    
    var storage: [String: Data] = [:]
    
    // MARK: INTERCEPTOR
    struct Interceptor {
        var called_save = 0
        var called_loadData = 0
        var called_removeData = 0
        
        static var clean: Interceptor { return Interceptor() }
    }
    
    var interceptor = Interceptor()
    
    // MARK: METHOD FOR TESTING
    func isDataExist(forKey key: String) -> Bool {
        return storage.index(forKey: key) != nil
    }
    
    func object<T: Decodable>(forKey key: String, decoder: JSONDecoder? = nil) -> T? {
        guard let data = storage[key] else {
            return nil
        }
        let decoderToUse: JSONDecoder
        if let decoder = decoder {
            decoderToUse = decoder
        } else {
            decoderToUse = JSONDecoder()
            decoderToUse.dataDecodingStrategy = .base64
            decoderToUse.dateDecodingStrategy = .secondsSince1970
        }
        guard let object = try? decoderToUse.decode(T.self, from: data) else {
            return nil
        }
        return object
    }
    
    func retrieveCacheData(forKey key: String) -> CacheData? {
        return object(forKey: key)
    }
    
    func removeAllData() {
        storage.removeAll()
    }
    
    // MARK: Secure Data Protocol Method
    func save(data: Data, forKey key: String) -> Bool {
        interceptor.called_save += 1
        storage[key] = data
        return true
    }
    
    func load(forKey key: String, status: UnsafeMutablePointer<OSStatus>?) -> Data? {
        interceptor.called_loadData += 1
        return storage[key]
    }
    
    func removeData(forKey key: String)
}
