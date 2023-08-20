//
//  UpdateSchedulerTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class UpdateSchedulerTests: XCTestCase {
    
    func test_pickNewer_sameCA() {
        
        let certificates: [CertInfo] = [
            CertInfo(commonName: .testCommonName_1, fingerprint: .testFingerprint_1, expirationDate: Date(timeIntervalSince1970: 200.0)),
            CertInfo(commonName: .testCommonName_1, fingerprint: .testFingerprint_2, expirationDate: Date(timeIntervalSince1970: 100.0))
        ]
        
        let scheduler = UpdateScheduler(intervalPeriod: 20.0, expirationThreshold: 10.0, thresholdMultiplier: 0.125)
        var now = Date(timeIntervalSince1970: 0)
        Debug.message("Current time: \(now)")
        var scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 20)
        
        now = Date(timeIntervalSince1970: 60.0)
        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 20)
        
        now = Date(timeIntervalSince1970: 180.0)
        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 20)

        now = Date(timeIntervalSince1970: 192.0)
        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == (200-192) * 0.125)
        
        now = Date(timeIntervalSince1970: 215.0)
        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 0)
    }
    
    func test_pickDifferentCA() {
        let certificates: [CertInfo] = [
            CertInfo(commonName: .testCommonName_1, fingerprint: .testFingerprint_1, expirationDate: Date(timeIntervalSince1970: 200.0)),
            CertInfo(commonName: .testCommonName_2, fingerprint: .testFingerprint_2, expirationDate: Date(timeIntervalSince1970: 100.0))
        ]
        
        let scheduler = UpdateScheduler(intervalPeriod: 20.0, expirationThreshold: 10.0, thresholdMultiplier: 0.125)
        var now = Date(timeIntervalSince1970: 0)
//        Debug.message("Current time: \(now)")
        var scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 20)
        
        now = Date(timeIntervalSince1970: 60.0)
//        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 20)
        
        now = Date(timeIntervalSince1970: 92.0)
//        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == (100-92)*0.125)

        now = Date(timeIntervalSince1970: 192.0)
//        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 0)
        
        now = Date(timeIntervalSince1970: 215.0)
//        Debug.message("Current time: \(now)")
        scheduled = scheduler.scheduleUpdate(certificates: certificates, currentDate: now)
        XCTAssertTrue(scheduled.timeIntervalSince(now) == 0)
    }
}
