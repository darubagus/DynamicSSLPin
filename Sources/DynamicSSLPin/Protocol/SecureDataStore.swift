//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 07/06/23.
//

import Foundation

public protocol SecureDataStore {
    
    @discardableResult
    func save(data: Data, forKey key: String) -> Bool
    
    func load(forKey key: String) -> Data?
    
    func removeData(forKey key: String)
}
