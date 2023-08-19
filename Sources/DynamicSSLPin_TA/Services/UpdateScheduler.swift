//
//  UpdateScheduler.swift
//  
//
//  Created by Daru Bagus Dananjaya on 07/07/23.
//

import Foundation

internal struct UpdateScheduler {
    let intervalPeriod: TimeInterval
    let expirationThreshold: TimeInterval
    let thresholdMultiplier: Double
    
    func scheduleUpdate(certificates: [CertInfo], currentDate: Date = Date()) -> Date {
        var preprocessedCommonNames = Set<String>()
        var nextUpcomingExpirationDate = currentDate.addingTimeInterval(60*60*24*365)
        
        for certificate in certificates {
            if preprocessedCommonNames.contains(certificate.commonName) {
                continue
            }
            preprocessedCommonNames.insert(certificate.commonName)
            nextUpcomingExpirationDate = min(nextUpcomingExpirationDate, certificate.expirationDate)
        }
        
        var nextExpirationInterval = nextUpcomingExpirationDate.timeIntervalSince(currentDate)
        
        if nextExpirationInterval > 0 {
            if nextExpirationInterval < expirationThreshold {
                nextExpirationInterval *= thresholdMultiplier
            }
        } else {
            nextExpirationInterval = 0
        }
        
        nextExpirationInterval = min(nextExpirationInterval, intervalPeriod)
        return currentDate.addingTimeInterval(nextExpirationInterval)
    }
}
