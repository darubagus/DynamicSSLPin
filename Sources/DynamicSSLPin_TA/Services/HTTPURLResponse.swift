//
//  HTTPURLResponse.swift
//  
//
//  Created by Daru Bagus Dananjaya on 04/07/23.
//

import Foundation

public extension HTTPURLResponse {
    var stringifyHeaders: [String:String] {
        return allHeaderFields
            .reduce(into: [:]) { result, tuple in
                guard let key = tuple.key as? String, let value = tuple.value as? String else {
                    return
                }
                
                result[key.lowercased()] = value
            }
    }
}
