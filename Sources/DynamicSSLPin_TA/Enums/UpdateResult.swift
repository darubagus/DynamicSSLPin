//
//  UpdateResult.swift
//  
//
//  Created by Daru Bagus Dananjaya on 06/07/23.
//

import Foundation

public enum UpdateResult {
    case ok
    case emptyStore
    case invalidData
    case invalidSignature
    case networkError
}
