//
//  CacheData.swift
//  
//
//  Created by Daru Bagus Dananjaya on 21/06/23.
//

import Foundation

internal struct CacheData: Codable {
    
    var certificates: [CertInfo]
    var nextUpdate: Date
    
    enum CodingKeys: String, CodingKey {
        case certificates = "c"
        case nextUpdate = "u"
    }
}

extension CacheData {
    func countValidCertificates(forDate date: Date) -> Int {
        var res = 0
        for certificate in certificates {
            if !certificate.isCertExpired(forDate: date) {
                res += 1
            }
        }
        return res
    }
}

extension Array where Element == CertInfo {
    mutating func sortCertificates() {
        self.sort { (lhs, rhs) -> Bool in
            if lhs.commonName == rhs.commonName {
                return lhs.expirationDate > rhs.expirationDate
            }
            return lhs.commonName < rhs.commonName
        }
    }
}
