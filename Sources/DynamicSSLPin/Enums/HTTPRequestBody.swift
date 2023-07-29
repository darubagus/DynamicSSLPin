//
//  HTTPRequestBody.swift
//  
//
//  Created by Daru Bagus Dananjaya on 03/07/23.
//

import Foundation

public enum HTTPRequestBody {
    case jsonDecodable
    case jsonEncodeable
    case formData([String: CustomStringConvertible?])
}

