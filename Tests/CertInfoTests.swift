//
//  CertInfoTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 20/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertInfoTests: XCTestCase {
    
    func test_sortingArrayOfCertInfo() {
        // MARK: F03-1 - F03-2
        var certificates: [CertInfo] = [
            CertInfo(commonName: .testCommonName_1, fingerprint: .testFingerprint_1, expirationDate: Date(timeIntervalSince1970: 200.0)),
            CertInfo(commonName: .testCommonName_1, fingerprint: .testFingerprint_2, expirationDate: Date(timeIntervalSince1970: 100.0)),
            CertInfo(commonName: .testCommonName_3, fingerprint: .testFingerprint_3, expirationDate: Date(timeIntervalSince1970: 400.0)),
            CertInfo(commonName: .testCommonName_Unknown, fingerprint: .testFingerprint_Unknown, expirationDate: Date(timeIntervalSince1970: 0))
        ]
        
        certificates.sortCertificates()
        
        XCTAssertTrue(certificates[0].commonName == .testCommonName_1)
        XCTAssertTrue(certificates[0].fingerprint == .testFingerprint_1)
        
        XCTAssertTrue(certificates[1].commonName == .testCommonName_1)
        XCTAssertTrue(certificates[1].fingerprint == .testFingerprint_2)
        
        XCTAssertTrue(certificates[2].commonName == .testCommonName_3)
        XCTAssertTrue(certificates[2].fingerprint == .testFingerprint_3)
        
        XCTAssertTrue(certificates[3].commonName == .testCommonName_Unknown)
        XCTAssertTrue(certificates[3].fingerprint == .testFingerprint_Unknown)
    }
}
