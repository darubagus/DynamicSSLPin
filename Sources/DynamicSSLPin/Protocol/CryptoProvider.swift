//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 07/06/23.
//

import Foundation

// do we need anyObject type here?
public protocol CryptoProvider {
    
    func validateSignatureECDSA(signedData: SignedData, pubKey: ECPublicKey) -> Bool
    
    func importECPublicKey(pubKey: Data) -> ECPublicKey?
    
    func hash(data: Data) -> Data
    
    func getRandomData(length: Int) -> Data
}
