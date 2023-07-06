//
//  CryptoKitCryptoProvider.swift
//  
//
//  Created by Daru Bagus Dananjaya on 16/06/23.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
public class CryptoKitCryptoProvider: CryptoProvider {
    
    public init () {}
    
    public func validateSignatureECDSA(signedData: SignedData, pubKey: ECPublicKey) -> Bool {
        
//        let publicKeyData =
//        let signingPubKey = try! P521.Signing.PublicKey(rawRepresentation: publicKeyData)
//
//        return signingPubKey.isValidSignature(signedData.signature, for: ECPublicKey)
        return true
    }
    
    public func importECPublicKey(pubKey: Data) -> Any? {
        return try! P521.Signing.PublicKey(rawRepresentation: pubKey)
    }
    
    public func hash(data: Data) -> Data {
        let digest = SHA384.hash(data: data)
        return convertDigestToData(digest: digest)
    }
    
    public func getRandomData(length: Int) -> Data {
        var data = Data(count: length)
        let res = data.withUnsafeMutableBytes { (ptr) -> Int32 in
            if let rawPointer = ptr.baseAddress {
                return SecRandomCopyBytes(kSecRandomDefault, length, rawPointer)
            }
            return errSecAllocate
        }
        guard res == errSecSuccess else {
            Debug.fatalError("Can't generate random")
        }
        return data
    }
    
}

@available(iOS 13.0, *)
extension CryptoProvider {
    func importECPubblicKey(pubKeyBase64: String) -> Any? {
        guard let publicKeyData = Data(base64Encoded: pubKeyBase64), let pubKey = importECPublicKey(pubKey: publicKeyData) else {
            Debug.fatalError("Invalid public key")
        }
        return pubKey
    }
    
    public func convertDigestToData(digest: SHA384Digest) -> Data {
        return digest.withUnsafeBytes { Data($0) }
    }
}
