//
//  UpdateTests.swift
//  DynamicSSLPin_TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import XCTest
@testable import DynamicSSLPin_TA

class CertStore_UpdateTests: XCTestCase {
    // MARK: Initiate Helpers
    var config: CertStoreConfig!
    var certStore: CertStore!
    
    var cryptoProvider: CryptoProviderTests!
    var secureDataStore: SecureDataStoreTests!
    var remoteDataProvider: RemoteDataProviderTests!
    
    let responseGenerator = ResponseGeneratorTests()
    
    // MARK: CertStore Preparation
    func prepareStore(with config: CertStoreConfig) {
        self.config = config
        cryptoProvider = CryptoProviderTests()
        secureDataStore = SecureDataStoreTests()
        remoteDataProvider = RemoteDataProviderTests()
        
        certStore = CertStore(configuration: config, cryptoProvider: cryptoProvider, secureDataStore: secureDataStore, remoteDataProvider: remoteDataProvider)
    }
    
    // MARK: [CERTSTORE_UPDATE] Unit Tests
    func test_update_wholeCycle() {
        // This method handle these following testcase
        // MARK: F07-1 - F07-6
        
        var updateResult: Result<UpdateResult, Error>
        var validationResult: ValidationResult
        var elapsedTime: TimeInterval
        let referenceDate = Date()
        
        prepareStore(with: .testConfig)
        
        // MARK: 1st Phase
        // Prepare initial certificate data which will be expired soon
        Debug.message("[1. Initial load] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        remoteDataProvider.setNoLatency().reportData = responseGenerator.removeAllEntry().append(commonName: .testCommonName_1, expirationDate: .soon, fingerprint: .testFingerprint_1).data()
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        XCTAssertTrue(updateResult.value == .ok)
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
        XCTAssertTrue(validationResult == .trusted)
        
        // MARK: 2nd Phase
        // Try to update, should not fetch data from remote server since the interval is too close from the last update
        Debug.message("[2. Try update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        
        remoteDataProvider.setLatency(.testLatency_ForSilentUpdate)
        remoteDataProvider.interceptor = .clean
        
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
        }
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 0)
        
        // MARK: Wait
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate / 2)
        
        // MARK: 3rd Phase
        // Should not fetch data from remote server since no certificate is going to expire soon
        Debug.message("[3. Try update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        remoteDataProvider.interceptor = .clean
        
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
        }
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 0)
        
        // MARK: Wait
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate / 2 + 0.1)
        
        // MARK: 4th Phase
        // Do update on the fly, periodic update will trigger silent update
        Debug.message("[4. Do silent update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                      Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .ok)
        }
        
        // Wait until silent update is completed
        Thread.waitFor(interval: .testLatency_ForFastUpdate)
        
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
        
        // MARK: 5th Phase
        // Since it is too close from previous update, it shouldn't fetch fingerprint from remote server
        Debug.message("[5. Try update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        remoteDataProvider.interceptor = .clean
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .ok)
        }
        
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
        
        // Wait for the next periodic update
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate)
        
        // MARK: 6th Phase
        // Do update triggered by periodic update
        Debug.message("[6. Periodic update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
     
        remoteDataProvider.interceptor = .clean
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .ok)
        }
        
        // Wait until update is finished
        Thread.waitFor(interval: .testLatency_ForFastUpdate)
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
        
        // Wait For Next Periodic Update
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate)
        
        // MARK: 7th Phase
        // Do update triggered by periodic update
        Debug.message("[7. Periodic update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        remoteDataProvider.interceptor = .clean
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .ok)
        }
        
        // Wait until update is finished
        Thread.waitFor(interval: .testLatency_ForFastUpdate)
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
        
        /**
         At this point, the program should wait until the update triggered by expiration date
         */
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate)
        
        // MARK: 8th Phase
        // Do update triggered by periodic update
        Debug.message("[8. Periodic update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        remoteDataProvider.interceptor = .clean
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .ok)
        }
        
        // Wait until update is finished
        Thread.waitFor(interval: .testLatency_ForFastUpdate)
        
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
        
        Thread.waitFor(interval: 1.0)
        
        // MARK: 9th Phase
        // Do update triggered by certificate expiration date
        Debug.message("[9. Periodic update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        remoteDataProvider.interceptor = .clean
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .ok)
        }
        
        // Wait until update is finished
        Thread.waitFor(interval: .testLatency_ForFastUpdate)
        
        XCTAssertTrue(elapsedTime < .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
        
        // Wait until the certificate is expired
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate)
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate)
        Thread.waitFor(interval: .testUpdateInterval_PeriodicUpdate)
        Thread.waitFor(interval: 2)
        
        // All Certificates should be expired by now
        
        // MARK: 10th Phase
        // Try blocking update
        Debug.message("[10. Try Blocking update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                          Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        remoteDataProvider.interceptor = .clean
        elapsedTime = Thread.measureElapsedTime {
            updateResult = AsyncHelper.wait { completion in
                certStore.update { (result, error) in
                    completion.complete(with: result)
                }
            }
            XCTAssertTrue(updateResult.value == .emptyStore)
        }
        XCTAssertTrue(elapsedTime > .testLatency_ForFastUpdate)
        XCTAssertTrue(remoteDataProvider.interceptor.called_fetchFingerprints == 1)
        
        // In case of update error, persistent storage will not be updated since the previous certificate is still trusted
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
        XCTAssertTrue(validationResult == .empty)
        
        remoteDataProvider.reportData = responseGenerator.append(commonName: .testCommonName_1, expirationDate: .valid, fingerprint: .testFingerprint_1).data()
        
        // MARK: 11th Phase
        // Do Blocking Update
        Debug.message("[11. Try Blocking update] Elapsed Time \(-referenceDate.timeIntervalSinceNow)")
        Debug.message("                          Next Update \(certStore.getCachedData()?.nextUpdate.timeIntervalSince(referenceDate) ?? -1)")
        
        updateResult = AsyncHelper.wait { completion in
            certStore.update { (result, error) in
                completion.complete(with: result)
            }
        }
        XCTAssertTrue(updateResult.value == .ok)
        XCTAssertTrue(certStore.getCachedData()?.certificates.count == 1)
        
        validationResult = certStore.validate(commonName: .testCommonName_1, fingerprint: .testFingerprint_1)
        XCTAssertTrue(validationResult == .trusted)
    }
}
