//
//  RemoteDataObject.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

class RemoteDataObject {
    
    // MARK: Enums
    enum RemoteError: Error {
        case invalidResponse
        case invalidResponseObject
        case invalidJSON
        case wrongStatusCode
    }

    // MARK: URL Attribute
    let session: URLSession
    let request: URLRequest

    // MARK: Constructor
    init(session: URLSession = URLSession.shared, request: URLRequest) {
        self.session = session
        self.request = request
    }
    
    private func getRemoteData() -> Data? {
        let result: Result<Data, Error> = AsyncHelper.wait(waitTimeout: 4.0) { completion in
            session.dataTask(with: request) { (data, response, error) in
                guard let response = response as? HTTPURLResponse else {
                    completion.complete(with: RemoteError.invalidResponseObject)
                    return
                }
                
                if response.statusCode > 299 {
                    completion.complete(with: RemoteError.wrongStatusCode)
                } else if let error = error {
                    completion.complete(with: error)
                } else if let data = data {
                    completion.complete(with: data)
                } else {
                    completion.complete(with: RemoteError.invalidResponse)
                }
                
            }.resume()
        }
        
        if case .success(let data) = result {
            return data
        }
        
        return nil
    }
}
