//
//  CryptoProviderTests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 13/08/23.
//

import Foundation
import DynamicSSLPin
import CryptoKit

class CryptoProviderTests{
    
    let cryptoKitCryptoProvider: CryptoProvider
    
    init() {
        cryptoKitCryptoProvider: CryptoKitCryptoProvider()
    }
    
    var failure_onECDSAValidation = false
    var failure_onImportECPublicKey = false
    
    var onECDSAValidation: ((SignedData, ))
}

