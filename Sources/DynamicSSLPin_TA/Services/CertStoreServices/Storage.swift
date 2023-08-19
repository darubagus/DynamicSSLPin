//
//  Storage.swift
//  
//
//  Created by Daru Bagus Dananjaya on 04/07/23.
//

import Foundation

@available(iOS 13.0, *)
internal extension CertStore {
    
    /**
     SAVE DATA TO CACHE
     */
    func saveData(data: CacheData) {
        let jsonUtil = JSONUtility()
        
        guard let encodedData = try? jsonUtil.jsonEncoder().encode(data) else {
            return
        }
        
        secureDataStore.save(data: encodedData, forKey: self.instanceID)
    }
    
    /**
     LOAD CACHED DATA
     */
    func loadCachedData() -> CacheData? {
        let jsonUtil = JSONUtility()
        
        guard let encodedData = secureDataStore.load(forKey: self.instanceID, status: nil) else {
            return nil
        }
        
        guard let cachedData = try? jsonUtil.jsonDecoder().decode(CacheData.self, from: encodedData) else {
            return nil
        }
        
        return cachedData
    }
    
    func loadFallbackCertificates() -> [CertInfo] {
        let jsonUtil = JSONUtility()
        
        guard let fallbackData = configuration.fallbackCertificate else {
            return []
        }
        
        guard let fallback = try? jsonUtil.jsonDecoder().decode(Fingerprint.self, from: fallbackData) else {
            return []
        }
        return fallback.fingerprints.map { try! CertInfo(from: $0) }
    }
}
