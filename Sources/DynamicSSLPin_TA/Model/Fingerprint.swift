//
//  Fingerprint.swift
//  
//
//  Created by Daru Bagus Dananjaya on 15/06/23.
//

import Foundation

internal struct Fingerprint: Codable {
    
    struct Entry: Codable {
        let name: String
        let fingerprint: Data
        let expirationDate: Date
        let signature: Data?
    }
    
    let fingerprints: [Entry]
    let timestamp: Date?
}

extension Fingerprint.Entry {
    
    var normalizedSignatureData: SignedData? {
        guard let signature = signature else {
            return nil
        }
        
        let expirationTimeStamp = String(format: "%.0f", ceil(expirationDate.timeIntervalSince1970))
        let signedString = "\(name)&\(expirationTimeStamp)&\(fingerprint.base64EncodedString())"
        
        guard let signedBytes = signedString.data(using: .utf8) else {
            return nil
        }
        
        return SignedData(data: signedBytes, signature: signature)
    }
}
