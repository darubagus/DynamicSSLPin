//
//  NetworkManager.swift
//  
//
//  Created by Daru Bagus Dananjaya on 02/07/23.
//

import Foundation

public class NetworkManager: NSObject, URLSessionDelegate, RemoteDataProvider {
    
    private let baseURL: URL
    private let sslValidationStrat: SSLValidationStrat
    private let execQueue: DispatchQueue
    private let delegateQueue: OperationQueue
    private lazy var session: URLSession = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: delegateQueue)
    
    internal init(baseURL: URL, sslValidationStrat: SSLValidationStrat) {
        self.baseURL = baseURL
        self.sslValidationStrat = sslValidationStrat
        let dispatchQueue = DispatchQueue(label: "DynamicSSLPinning")
        self.execQueue = dispatchQueue
        self.delegateQueue = OperationQueue()
        self.delegateQueue.underlyingQueue = dispatchQueue
    }
    
    
    func fetchFingerprints(request: RemoteDataRequest, completion: @escaping (RemoteDateResponse) -> Void) {
        execQueue.async {
            [weak self] in
            
            guard let this = self else {
                return
            }
            
            var urlRequest = URLRequest(url: this.baseURL)
            
            request.requestHeader.forEach { key, value in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
            
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //logger
            Debug.logHTTPRequest(request: urlRequest)
            
            
            this.session.dataTask(with: urlRequest) { data, response, error in
            Debug.logHTTPResponse(response: response, data: data, error: error)
                
                if let error {
                    completion(RemoteDateResponse(responseHeader: [:], results: .failure(NetworkError.internalError(message: "Invalid Response Object"))))
                    return
                }
                
                let response = response as? HTTPURLResponse
                let headers = response?.stringifyHeaders
                let statusCode = response?.statusCode
                
                if statusCode! > 299 {
                    Debug.message("NetworkManager: Request failed with response code: \(statusCode)")
                    completion(RemoteDateResponse(responseHeader: headers!, results: .failure(NetworkError.invalidHTTPResponse(statusCode: statusCode!))))
                } else if let error = error {
                    Debug.message("NetworkManager: Request failed with error \(error)")
                    completion(RemoteDateResponse(responseHeader: headers!, results: .failure(error)))
                } else if let data = data {
                    completion(RemoteDateResponse(responseHeader: headers!, results: .success(data)))
                } else {
                    Debug.message("NetworkManager: Request finished with empty response")
                    completion(RemoteDateResponse(responseHeader: headers!, results: .failure(NetworkError.nilResponseData)))
                }
            }.resume()
        }
    }
    
}

