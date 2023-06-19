//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 07/06/23.
//

import Foundation
import CryptoKit

// do we need anyObject type here?
@available(iOS 13.0, *)
public protocol CryptoProvider {
    
    func validateSignatureECDSA(signedData: SignedData, pubKey: ECPublicKey) -> Bool
    
    func importECPublicKey(pubKey: Data) -> Any?
    
    func hash(data: Data) -> SHA384Digest
    
    func getRandomData(length: Int) -> Data
}
