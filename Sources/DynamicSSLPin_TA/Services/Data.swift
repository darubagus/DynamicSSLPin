//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 04/07/23.
//

import Foundation

public extension Data {
    static func bodyToString(body: Data?) -> String {
        guard let data = body, !data.isEmpty else {
            return "Empty"
        }
        
        guard let result = String(data: data, encoding: .utf8) else {
            return data.base64EncodedString()
        }
        
        return result
    }
}
