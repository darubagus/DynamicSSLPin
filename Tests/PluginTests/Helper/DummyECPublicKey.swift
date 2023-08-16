//
//  DummyECPublicKey.swift
//  
//
//  Created by Daru Bagus Dananjaya on 13/08/23.
//

import Foundation
import CryptoKit

class DummyECPublicKey {
    let keyName: String
    
    init(keyname: String?) {
        self.keyName = keyname ?? "defaultKeyName"
    }
}
