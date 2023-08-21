//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 05/07/23.
//

import Foundation

@available(iOS 13.0, *)
public extension CertStore {
    func validate(challenge: URLAuthenticationChallenge) -> ValidationResult {
        guard let serverTrust = challenge.protectionSpace.serverTrust, let serverCertChain = SecTrustCopyCertificateChain(serverTrust) as? Array<SecCertificate>, let serverCert = serverCertChain[0] as SecCertificate?, let commonName = SecCertificateCopySubjectSummary(serverCert) as String? else {
            return .untrusted
        }
        
        let certData = SecCertificateCopyData(serverCert) as Data
        
        // to be changed
        return validate(commonName: commonName, certData: certData)
    }
    
    func validate(commonName: String, certData: Data) -> ValidationResult {
        let fingerprint = cryptoProvider.hash(data: certData)
        
        // to be changed
        return validate(commonName: commonName, fingerprint: fingerprint)
    }
    
    func validate(commonName: String, fingerprint: Data) -> ValidationResult {
        if let expectedCommonNames = configuration.expectedCommonNames {
            guard expectedCommonNames.contains(commonName) else {
                return .untrusted
            }
        }
        
        let listOfCertificates = getAllCertificate()
        Debug.message("List of Certificates: \(listOfCertificates)")
        
        if listOfCertificates.count == 0 {
            return .empty
        }
        
        let currentDate = Date()
        var attempts = 0
        
        for certInfo in listOfCertificates {
            if certInfo.isCertExpired(forDate: currentDate) {
                continue
            }
            
            if certInfo.commonName == commonName {
                if certInfo.fingerprint == fingerprint {
                    return .trusted
                }
                attempts += 1
            }
        }
        
        if attempts > 0 {
            // Because there shouldn't be any duplicate entry for one commonName
            return .untrusted
        } else {
            return .empty
        }
    }
    
    func showAllCertificates() {
        Debug.message("\(getAllCertificate())")
    }
}
