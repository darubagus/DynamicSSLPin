//
//  ResponseGeneratorTests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation
@testable import DynamicSSLPin_TA

fileprivate extension Fingerprint.Entry {
    
    static func create(commonName: String, expiration: Expiration, fingerprint: Data?, signature: Data?) -> Fingerprint.Entry {
        return Fingerprint.Entry(
            name: commonName,
            fingerprint: fingerprint ?? .random(count: 32),
            expires: expiration.toDate,
            signature: signature
        )
    }
}

extension Fingerprint {
    
    static func single(commonName: String, expiration: Expiration, fingerprint: Data? = nil, timestamp: Date? = nil) -> Fingerprint {
        return Fingerprint(fingerprints: [.create(commonName: commonName, expiration: expiration, fingerprint: fingerprint, signature: nil)], timestamp: timestamp)
    }
}
