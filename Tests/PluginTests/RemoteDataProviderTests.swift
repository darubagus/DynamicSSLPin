//
//  RemoteDataProviderTests.swift
//  
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

@testable import DynamicSSLPin_TA

class RemoteDataProviderTests: RemoteDataProvider {
    
    // MARK: Interceptor
    struct Interceptor {
        var called_fetchFingerprints = 0
        
        static var clean: Interceptor { return Interceptor() }
    }
    
    var interceptor = Interceptor()
    
    // MARK: Enums
    enum SimulatedError: Error {
        case networkError
    }
    
    // MARK: Response Related Data
    typealias Response = (data: Data?, headers: [String:String])
    
    var reportError = false
    var reportData: Data?
    
    var simulateResponseTime: TimeInterval = 0.200
    var simulateResponseTimeVariability: TimeInterval = 0.8
    
    var dataGenerator: (([String:String])->Response)?
    
    // MARK: Remote Data Provider Util
    @discardableResult
    func setReportError(_ enabled: Bool) -> RemoteDataProviderTests {
        reportError = enabled
        return self
    }
    
    @discardableResult
    func setNoLatency() -> RemoteDataProviderTests {
        simulateResponseTime = 0
        simulateResponseTimeVariability = 0
        return self
    }
    
    @discardableResult
    func setLatency(_ latency: TimeInterval) -> RemoteDataProviderTests {
        simulateResponseTime = latency
        simulateResponseTimeVariability = 0
        return self
    }
    
    @discardableResult
    func setLatency(min: TimeInterval, max: TimeInterval) -> RemoteDataProviderTests {
        simulateResponseTime = min
        simulateResponseTimeVariability = max - min
        return self
    }
    
    // MARK: RDP Implementation
    func fetchFingerprints(request: RemoteDataRequest, completion: @escaping (RemoteDataResponse) -> Void) {
        interceptor.called_fetchFingerprints += 1
        
        DispatchQueue.global().async {
            if self.simulateResponseTime > 0 {
                let timeInterval: TimeInterval = self.simulateResponseTime + self.simulateResponseTimeVariability * 0.01 * TimeInterval(arc4random_uniform(100))
                Thread.sleep(forTimeInterval: timeInterval)
            }
            
            let response: Response
            if !self.reportError {
                if let generator = self.dataGenerator {
                    response = generator(request.requestHeader)
                } else {
                    response = (self.reportData, [:])
                }
            } else {
                response = (nil, [:])
            }
            if let data = response.data {
                completion(RemoteDataResponse(responseHeader: response.headers, results: .success(data)))
            } else {
                completion(RemoteDataResponse(responseHeader: response.headers, results: .failure(SimulatedError.networkError)))
            }
        }
        
    }
}