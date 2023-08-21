//
//  Result.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

extension Result {
    
    var value: Success? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
}
