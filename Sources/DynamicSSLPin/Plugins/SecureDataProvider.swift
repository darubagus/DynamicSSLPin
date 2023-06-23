//
//  SecureDataProvider.swift
//  
//
//  Created by Daru Bagus Dananjaya on 21/06/23.
//

import Foundation
import KeychainAccess
import PowerAuth2

public class SecureDataProvider: SecureDataStore {

    public static let defaultKeychainIdent: String = "com.darubagus.CertStore"

    private let keychain: PowerAuthKeychain

    public init(keychainIdentifier: String = SecureDataProvider.defaultKeychainIdent, accessGroup: String? = nil) {
        self.keychain = PowerAuthKeychain(identifier: keychainIdentifier, accessGroup: accessGroup)
    }

    public func save(data: Data, forKey key: String) -> Bool {
        if keychain.containsData(forKey: key) {
            return keychain.updateValue(data, forKey: key) == .ok
        } else {
            return keychain.addValue(data, forKey: key) == .ok
        }
    }

    public func load(forKey key: String, status: UnsafeMutablePointer<OSStatus>? = nil) -> Data? {
        return keychain.data(forKey: key, status: status)
    }

    public func removeData(forKey key: String) {
        keychain.deleteData(forKey: key)
    }


}

