//
//  certInfo.swift
//  
//
//  Created by Daru Bagus Dananjaya on 21/06/23.
//

import Foundation

internal struct CertInfo: Codable {
    
    let commonName: String
    let fingerprint: Data
    let expirationDate: Date
    
    enum CodingKeys: String, CodingKey {
        case commonName = "c"
        case fingerprint = "f"
        case expirationDate = "e"
    }
}

extension CertInfo {
    init(from entry: Fingerprint.Entry) throws {
        self.commonName = entry.name
        self.fingerprint = entry.fingerprint
        self.expirationDate = entry.expirationDate
    }
    
    func isCertExpired(forDate date: Date) -> Bool {
        return expirationDate.timeIntervalSince(date) < 0
    }
}

extension CertInfo: Equatable {
    static func isCertMatch(lhs: CertInfo, rhs: CertInfo) -> Bool {
        return (lhs.commonName == rhs.commonName && lhs.expirationDate == rhs.expirationDate && lhs.fingerprint == rhs.fingerprint)
    }
}
