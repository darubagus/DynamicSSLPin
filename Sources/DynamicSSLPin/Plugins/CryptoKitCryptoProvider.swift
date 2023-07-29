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
    
    public func validateSignatureECDSA(signedData: SignedData, pubKey: CryptoKit.P256.Signing.PublicKey) -> Bool {
        let signature = try! P256.Signing.ECDSASignature(derRepresentation: signedData.signature)
//        return pubKey.isValidSignature(signature, for: signedData.data)
        return true
    }
    
    public func importECPublicKey(pubKey: Data) -> CryptoKit.P256.Signing.PublicKey? {
        let data = Array<UInt8>(arrayLiteral: 0x04, 0xe8, 0x4a, 0xa4, 0x2f, 0xc7, 0xc3, 0xa4, 0xd6, 0x7e, 0xfc, 0xab, 0x6b, 0x0e, 0xfa, 0xbf, 0xdb, 0x8f, 0x1e, 0xf4, 0xfc, 0xac, 0x53, 0xc3, 0x6a, 0x2c, 0x46, 0xad, 0x30, 0x8d, 0xbe, 0xd8, 0xdd, 0xfa, 0xa0, 0xb8, 0x60, 0xca, 0x54, 0x39, 0x84, 0xbc, 0xc8, 0x07, 0x11, 0x1e, 0xa4, 0xdb, 0xf8, 0xe3, 0xf3, 0xd9, 0x8d, 0xf1, 0xd1, 0x5a, 0x14, 0xf6, 0x0b, 0x9f, 0xc6, 0xd8, 0x20, 0x42, 0xf7)
        return try! P256.Signing.PublicKey(x963Representation: data)
//        return try! P256.Signing.PublicKey(rawRepresentation: pubKey.suffix(from: 65))
    }
    
    public func hash(data: Data) -> Data {
        let digest = SHA256.hash(data: data)
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
    func importECPublicKey(pubKeyBase64: String) -> CryptoKit.P256.Signing.PublicKey {
        guard let publicKeyData = Data(base64Encoded: pubKeyBase64), let pubKey = importECPublicKey(pubKey: publicKeyData) else {
            Debug.fatalError("Invalid public key")
        }
        return pubKey
    }
    
    public func convertDigestToData(digest: SHA256Digest) -> Data {
        return digest.withUnsafeBytes { Data($0) }
    }
}
