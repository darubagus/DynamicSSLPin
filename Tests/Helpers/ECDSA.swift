//
//  ECDSA.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation
import CryptoKit
@testable import DynamicSSLPin_TA

class ECDSA {
    typealias PrivateKey = P256.Signing.PrivateKey
    typealias PublicKey = P256.Signing.PublicKey
    
    struct KeyPair {
        let privateKey: PrivateKey
        let publicKey: PublicKey
    }
    
    static func generateKeyPair() -> KeyPair {
        let privateKey = PrivateKey(compactRepresentable: true)
        return KeyPair(privateKey: privateKey, publicKey: privateKey.publicKey)
    }
    
    static func sign(privateKey: PrivateKey, data: Data) -> Data {
        do {
            let signature = try privateKey.signature(for: data)
            return signature.derRepresentation
        } catch {
            Debug.fatalError("Signature computation failed. Error: \(error)")
        }
    }
    
    static func verify(publicKey: PublicKey, data: Data, signature: Data) -> Bool {
        do {
            let signature = try P256.Signing.ECDSASignature(derRepresentation: signature)
            return publicKey.isValidSignature(signature, for: data)
        } catch {
            Debug.message("Signature validation failed. Error: \(error)")
            return false
        }
    }
}

extension ECDSA.PublicKey {
    var stringRepresentation: String {
        return x963Representation.base64EncodedString()
    }
}
