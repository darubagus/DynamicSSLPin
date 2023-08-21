//
//  CryptoKitTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 20/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CryptoKitTests: XCTestCase {
    
    let validSignature  = ""
    
    func test_SHA256() {
        // MARK: F08-1
        let cryptoProvider = CryptoKitCryptoProvider()
        
        let testData = [
        ("test1234","937e8d5fbb48bd4949536cd65b8d35c426b80d2f830c5c308e2cdec422ae2244"),
        ("t/e=st=","14605d0401d1169ce232fe2a7291cb182f2c2e35e0e6cc7306d1305410b33a77"),
        ("1234567890=","65398d03a25017f375b63eb8423737bb8dda162ddd7c9be6d397de6ce8e89d71"),
        ("abcDEFghiJKLmnoPQRstuVWXyz","eaac2808399e406e28fca745b553af94f1d467b93394a28a45a899197b553f95"),
        ("abcdefghijklmnopqrstuvwxyz","71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73"),
        ("","e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        ]
        
        testData.forEach { (data, hash) in
            guard let dataBytes = data.data(using: .utf8) else {
                XCTFail("Wrong format data")
                return
            }
            
            guard let expectedHash = Data.fromHex(hash) else {
                XCTFail("Wrong format data")
                return
            }
            
            let generated = cryptoProvider.hash(data: dataBytes)
            XCTAssertEqual(expectedHash, generated)
        }
    }
    
    func test_ECDSA_P256_Validation_Success() {
        // MARK: F06-1
        let cryptoProvider = CryptoKitCryptoProvider()
        
        let commonName = "*.openweathermap.org"
        let fingerprint = "wJqbXkVEvII7szs7LV0lSTmCkff1CBJfgcGIKwpruKQ="
        let expirationDate = "1722383999"
        
        guard
            let publicKeyData: Data? = .validPublicKey,
            let signedData = "\(commonName)&\(expirationDate)&\(fingerprint)".data(using: .utf8),
            let signature = Data(base64Encoded: "MEQCIAEqNLehM07A6lJaJKub7JtPk9TvjShbI/c10Q+6myVRAiBHo5o5Xw6dQ3Snu4wufVCYTXASxoLSONdkznEMhNapfQ==")
        else {
            XCTFail("Wrong format data")
            return
        }
        
        guard let pubKey = cryptoProvider.importECPublicKey(pubKey: publicKeyData!) else {
            XCTFail("Import EC Public Key Failed")
            return
        }
        
        let signedDataObject = SignedData(data: signedData, signature: signature)
        XCTAssertTrue(cryptoProvider.validateSignatureECDSA(signedData: signedDataObject, pubKey: pubKey))
    }
    
    func test_ECDSA_P256_Validation_Failed_InvalidSignature() {
        // MARK: F06-2
        let cryptoProvider = CryptoKitCryptoProvider()
        
        let commonName = "*.openweathermap.org"
        let fingerprint = "wJqbXkVEvII7szs7LV0lSTmCkff1CBJfgcGIKwpruKQ="
        let expirationDate = "1722383999"
        
        guard
            let publicKeyData: Data? = .validPublicKey,
            let signedData = "\(commonName)&\(expirationDate)&\(fingerprint)".data(using: .utf8),
            let signature = Data(base64Encoded: "MEQCIAEqNLehM07A6lJaJKub7JtPk9TjvShbI/c10Q+6myVRAiBHo5o5Xw6dQ3Snu4wufVCYTXASxoLSONdkznEMhNapfQ==")
        else {
            XCTFail("Wrong format data")
            return
        }
        
        guard let pubKey = cryptoProvider.importECPublicKey(pubKey: publicKeyData!) else {
            XCTFail("Import EC Public Key Failed")
            return
        }
        
        let signedDataObject = SignedData(data: signedData, signature: signature)
        XCTAssertFalse(cryptoProvider.validateSignatureECDSA(signedData: signedDataObject, pubKey: pubKey))
    }
    
    func test_ECDSA_P256_Validation_Failed_InvalidPublicKey() {
        // MARK: F06-3
        let cryptoProvider = CryptoKitCryptoProvider()
        
        let commonName = "*.openweathermap.org"
        let fingerprint = "wJqbXkVEvII7szs7LV0lSTmCkff1CBJfgcGIKwpruKQ="
        let expirationDate = "1722383999"
        
        guard
            let publicKeyData: Data? = .invalidPublicKey,
            let signedData = "\(commonName)&\(expirationDate)&\(fingerprint)".data(using: .utf8),
            let signature: Data? = .validSignature
        else {
            XCTFail("Wrong format data")
            return
        }
        
        guard let pubKey = cryptoProvider.importECPublicKey(pubKey: publicKeyData!) else {
            XCTFail("Import EC Public Key Failed")
            return
        }
        
        let signedDataObject = SignedData(data: signedData, signature: signature!)
        XCTAssertFalse(cryptoProvider.validateSignatureECDSA(signedData: signedDataObject, pubKey: pubKey))
    }
    
    func test_ECDSA_P256_Validation_Failed_InvalidData() {
        // MARK: F06-4
        let cryptoProvider = CryptoKitCryptoProvider()
        
        let commonName = "*.openweathermap.org"
        let fingerprint = "wJqbXkVEvII7szs7LV0lSTmCkff1CBJfgcGIKwpruKQ="
        let expirationDate = "1722383999"
        
        guard
            let publicKeyData: Data? = .invalidPublicKey,
            let signedData = "\(commonName)&\(expirationDate)&\(fingerprint)&InvalidData".data(using: .utf8),
            let signature: Data? = .validSignature
        else {
            XCTFail("Wrong format data")
            return
        }
        
        guard let pubKey = cryptoProvider.importECPublicKey(pubKey: publicKeyData!) else {
            XCTFail("Import EC Public Key Failed")
            return
        }
        
        let signedDataObject = SignedData(data: signedData, signature: signature!)
        XCTAssertFalse(cryptoProvider.validateSignatureECDSA(signedData: signedDataObject, pubKey: pubKey))
    }
}
