//
//  ResponseGeneratorTests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

@testable import DynamicSSLPin_TA

class ResponseGeneratorTests {
    
    // MARK: Attribute
    var fingerprints: [Fingerprint.Entry] = []
    var isUsingTimestamp = false
    var signData: ((Data) -> Data)?
    
    // MARK: [METHODS] ENTRY UTIL
    
    private func createEntry(commonName: String, expirationDate: Expiration, fingerprint: Data? = .getRandomData(length: 32)) -> Fingerprint.Entry {
        let fingerprint = fingerprint
        let signature: Data?
        if let signData = signData {
            let expirationTimeStamp = String(format: "%.0f", ceil(expirationDate.toDate.timeIntervalSince1970))
            let signedString = "\(commonName)&\(expirationTimeStamp)&\(fingerprint!.base64EncodedString())"
            
            guard let signedByte = signedString.data(using: .utf8) else {
                Debug.fatalError("Failed to prepare data for signing")
            }
            
            signature = signData(signedByte)
        } else {
            signature = .getRandomData(length: 64)
        }
        return .create(commonName: commonName, expiration: expirationDate, fingerprint: fingerprint, signature: signature)
    }
    
    @discardableResult
    func signEntry(with privateKey: ECDSA.PrivateKey) -> ResponseGeneratorTests {
        self.signData = { bytes in
            return ECDSA.sign(privateKey: privateKey, data: bytes)
        }
        return self
    }
    
    @discardableResult
    func setUsingTimeStamp(useTimeStamp: Bool) -> ResponseGeneratorTests {
        self.isUsingTimestamp = useTimeStamp
        return self
    }
    
    func data() -> Data {
        var now: Date? = nil
        
        if isUsingTimestamp {
            now = Date()
        }
        
        return Fingerprint(fingerprints: fingerprints, timestamp: now).toJSON()
    }
    
    // MARK: [METHODS] ARRAY OF FINGERPRINT UTILITY
    @discardableResult
    func append(commonName: String, expirationDate: Expiration = .valid, fingerprint: Data? = nil) -> ResponseGeneratorTests {
        fingerprints.append(createEntry(commonName: commonName, expirationDate: expirationDate, fingerprint: fingerprint))
        return self
    }
    
    @discardableResult
    func insertAtIndex(commonName: String, expirationDate: Expiration = .valid, fingerprint: Data? = nil, index: Int? = 0) -> ResponseGeneratorTests {
        fingerprints.insert(createEntry(commonName: commonName, expirationDate: expirationDate, fingerprint: fingerprint), at: index!)
        return self
    }
    
    @discardableResult
    func insertFirst(commonName: String, expirationDate: Expiration = .valid, fingerprint: Data? = nil) -> ResponseGeneratorTests {
        insertAtIndex(commonName: commonName, expirationDate: expirationDate, fingerprint: fingerprint)
    }
    
    @discardableResult
    func duplicateThenAppendLast() -> ResponseGeneratorTests {
        if let last = fingerprints.last {
            fingerprints.append(last)
        }
        return self
    }
    
    @discardableResult
    func removeAllEntry() -> ResponseGeneratorTests {
        fingerprints.removeAll()
        return self
    }
}


// MARK: EXTENSION OF FINGERPRINT ENTRY
fileprivate extension Fingerprint.Entry {
    
    static func create(commonName: String, expiration: Expiration, fingerprint: Data? = .getRandomData(length: 32), signature: Data?) -> Fingerprint.Entry {
        return Fingerprint.Entry(
            name: commonName,
            fingerprint: fingerprint!,
            expirationDate: expiration.toDate,
            signature: signature
        )
    }
}

// MARK: EXTENSION OF FINGERPRINT
extension Fingerprint {
    
    static func single(commonName: String, expiration: Expiration, fingerprint: Data? = nil, timestamp: Date? = nil) -> Fingerprint {
        return Fingerprint(fingerprints: [.create(commonName: commonName, expiration: expiration, fingerprint: fingerprint, signature: nil)], timestamp: timestamp)
    }
}
