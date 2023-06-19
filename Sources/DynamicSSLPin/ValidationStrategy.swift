//
//  ValidationStrategy.swift
//  
//
//  Created by Daru Bagus Dananjaya on 07/06/23.
//

import Foundation

public enum SSLValidationStrat {
    case `default`
    case noValidation
}

extension SSLValidationStrat {
    func validate(challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        switch self {
        case .noValidation:
            if let serverTrust = challenge.protectionSpace.serverTrust {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            }
            break
        case .default:
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
