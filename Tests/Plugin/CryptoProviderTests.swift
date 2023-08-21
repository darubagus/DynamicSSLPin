//
//  CryptoProviderTests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 13/08/23.
//

import Foundation
import DynamicSSLPin_TA
import CryptoKit

class CryptoProviderTests{
    
    let cryptoKitCryptoProvider: CryptoProvider
    
    init() {
        cryptoKitCryptoProvider: CryptoKitCryptoProvider()
    }
    
    var failure_onECDSAValidation = false
    var failure_onImportECPublicKey = false
    
    var onECDSAValidation: ((SignedData, DummyECPublicKey) -> Bool)?
    
    // MARK: INTERCEPTOR
    struct Interceptor {
        var called_ecdsaValidateSignatures = 0
        var called_importECPublicKey = 0
        var called_hashSha256 = 0
        var called_getRandomData = 0
        
        static var clean: Interceptor { return Interceptor() }
    }
    
    var interceptor = Interceptor()
    
    // MARK: METHOD FOR TESTING
    
    func validateSignatureECDSA(signedData: SignedData, publicKey: CryptoKit.P256.Signing.PublicKey) -> Bool {
        interceptor.called_ecdsaValidateSignatures += 1
        if let closure = onECDSAValidation {
            return closure(signedData, publicKey)
        }
        return failure_onECDSAValidation == false
    }
    
    func importECPublicKey(pubKey: Data) -> CryptoKit.P256.Signing.PublicKey? {
        interceptor.called_importECPublicKey += 1
        if failure_onImportECPublicKey == false {
            let keyName = String(data: pubKey, encoding: .utf8)
            return DummyECPublicKey(keyname: keyName)
        }
        return nil
    }
    
    func hash(data: Data) -> Data {
        interceptor.called_hashSha256 += 1
        return cryptoKitCryptoProvider.hash(data: data)
    }
    
    func getRandomData(length: Int) -> Data {
        interceptor.called_getRandomData += 1
        return cryptoKitCryptoProvider.getRandomData(length: length)
    }
}

class DummyECPublicKey: CryptoKit.P256.Signing.PublicKey? {
    let keyName: String
    
    init(keyname: String?) {
        self.keyName = keyname ?? "defaultKeyName"
    }
}
