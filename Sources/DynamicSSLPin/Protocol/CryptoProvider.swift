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
    
    func validateSignatureECDSA(signedData: SignedData, pubKey: CryptoKit.P256.Signing.PublicKey) -> Bool
    
    func importECPublicKey(pubKey: Data) -> CryptoKit.P256.Signing.PublicKey?
    
    func hash(data: Data) -> Data
    
    func getRandomData(length: Int) -> Data
    
    func convertDigestToData(digest: SHA256Digest) -> Data
}
