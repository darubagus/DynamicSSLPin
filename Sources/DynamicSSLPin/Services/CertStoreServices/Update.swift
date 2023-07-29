//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 06/07/23.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
public extension CertStore {
    func update(mode: UpdateMode = .default, completionQueue: DispatchQueue = .main, completion: @escaping (_ result: UpdateResult, _ error: Error?) -> Void) {
        let currentDate = Date()
        let cachedData = getCachedData()
        
        var needsDirectUpdate = true
        var needsSilentUpdate = false
        
        if let cachedData = cachedData {
            needsDirectUpdate = cachedData.countValidCertificates(forDate: currentDate) == 0 || mode == .forced
            if !needsDirectUpdate {
                needsSilentUpdate = cachedData.nextUpdate < currentDate
            }
        }
        
        if needsDirectUpdate {
            // do update
            doUpdate(currentDate: currentDate, completionQueue: completionQueue, completion: completion)
        } else {
            if needsSilentUpdate {
                // do update
                doUpdate(currentDate: currentDate, completionQueue: nil, completion: nil)
            }
            completionQueue.async {
                completion(.ok, nil)
            }
        }
    }
    
    private func doUpdate(currentDate: Date, completionQueue: DispatchQueue?, completion: ((UpdateResult, Error?) -> Void)?) -> Void {
        var requestHeader = [String:String]()
        let requestChallenge: String?
        
        // ROOM FOR IMPROVEMENT
        if configuration.useChallenge {
            let randomChallenge = cryptoProvider.getRandomData(length: 16).base64EncodedString()
            requestHeader["X-Cert-Pinning-Challenge"] = randomChallenge
            requestChallenge = randomChallenge
        } else {
            requestChallenge = nil
        }
        
        let requestRemoteData = RemoteDataRequest(requestHeader: requestHeader)
        remoteDataProvider.fetchFingerprints(request: requestRemoteData) { response in
            let result: UpdateResult
            let error: Error?
            switch response.results {
            case .success(let data):
                //process received data
                result = self.processReceivedData(data, challenge: requestChallenge, responseHeader: response.responseHeader, currentDate: currentDate)
                error = nil
            case .failure(let errorResponse):
                result = .networkError
                error = errorResponse
            }
            completionQueue?.async {
                completion?(result, error)
            }
            
        }
    }
    
    private func processReceivedData(_ data: Data, challenge: String?, responseHeader: [String:String], currentDate: Date) -> UpdateResult {
        let publicKey = cryptoProvider.importECPublicKey(pubKeyBase64: configuration.pubKey)
        
        // ROOM FOR IMPROVEMENT
        if configuration.useChallenge {
            guard let challenge = challenge else {
                Debug.fatalError("processReceivedData: Challenge not set")
            }
            guard let signature = responseHeader["x-cert-pinning-signature"] else {
                Debug.message("processReceivedData: Missing signature header")
                return .invalidSignature
            }
            guard let signatureData = Data(base64Encoded: signature) else {
                return.invalidSignature
            }
            
            var signedData = Data(challenge.utf8)
            signedData.append(Data("&".utf8))
            signedData.append(data)
            
            guard cryptoProvider.validateSignatureECDSA(signedData: SignedData(data: signedData, signature: signatureData), pubKey: publicKey as! CryptoKit.P256.Signing.PublicKey) else {
                Debug.message("processReceivedData: Invalid Signature")
                return .invalidSignature
            }
        }
        
        let jsonUtil = JSONUtility()
        guard let response = try? jsonUtil.jsonDecoder().decode(Fingerprint.self, from: data) else {
            Debug.message("processReceivedData: Failed to parse JSON data from remote")
            return .invalidData
        }
        var result = UpdateResult.ok
        
        updateCachedData { (cachedData) -> CacheData? in
            var newCert = (cachedData?.certificates ?? []).filter {  !$0.isCertExpired(forDate: currentDate) }
            
            for entry in response.fingerprints {
                let newCertInfo = try! CertInfo(from: entry)
                Debug.message("new \(newCertInfo)")
                if newCertInfo.isCertExpired(forDate: currentDate) || newCert.firstIndex(of: newCertInfo) != nil {
                    // if entry is expired already, just proceed to next entry
                    // OR
                    // if entry is already exist in storage, just proceed to next entry
                    continue
                }
                
                if !configuration.useChallenge {
                    guard let signedData = entry.normalizedSignatureData else {
                        if entry.signature == nil {
                            Debug.message("processReceivedData: Missing signature for \(entry.name)")
                        } else {
                            Debug.message("processReceivedData: Unable to prepare data for signature validation for \(entry.name)")
                        }
                        result = .invalidData
                        break
                    }
                    guard cryptoProvider.validateSignatureECDSA(signedData: signedData, pubKey: publicKey as CryptoKit.P256.Signing.PublicKey) else {
                        Debug.message("CertStore: Invalid Signature for \(entry.name)")
                        result = .invalidSignature
                        break
                    }
                }
                
                if let expected = self.configuration.expectedCommonNames {
                    if !expected.contains(newCertInfo.commonName) {
                        Debug.message("CertStore: Common name \(entry.name) is not expected, but will be stored anyway")
                    }
                }
                newCert.append(newCertInfo)
                Debug.message("Append certificate successful")
            }
            
            if newCert.isEmpty && result == .ok {
                Debug.message("CertStore: Storage still empty")
                result = .emptyStore
            }
            
            guard result == .ok else {
                return nil
            }
            
            let scheduler = UpdateScheduler(intervalPeriod: configuration.updateInterval, expirationThreshold: configuration.expirationThreshold, thresholdMultiplier: 0.2)
            let nextUpdate = scheduler.scheduleUpdate(certificates: newCert, currentDate: currentDate)
            
            return CacheData(certificates: newCert, nextUpdate: nextUpdate)
        }
        Debug.message("Update Finished")
       return result
    }
}
