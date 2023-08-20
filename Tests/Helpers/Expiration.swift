//
//  Expiration.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

enum Expiration {
    /// Expiration will be set as "expired"
    case expired
    /// The certificate will expire really soon
    case verySoon
    /// The certificate will expire soon
    case soon
    /// The certificate expiration will be set to the future (2 x "soon" timeout)
    case valid
    /// The certificate will never expire.
    case never
}

extension Expiration {
    
    /// Converts Expiration enum into date, with appropriate offset to current date.
    var toDate: Date {
        return Date(timeIntervalSinceNow: toInterval)
    }
    
    var toInterval: TimeInterval {
        switch self {
        case .expired:  return -100
        case .verySoon: return .testExpiration_VerySoon
        case .soon:     return .testExpiration_Soon
        case .valid:    return .testExpiration_Valid
        case .never:    return .testExpiration_Never
        }
    }
}
