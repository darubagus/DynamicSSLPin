//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 04/07/23.
//

import Foundation

public extension Debug {
    static func logHTTPRequest(request: URLRequest) {
        let httpMethod = request.httpMethod ?? nil
        let baseURL = request.url?.absoluteString ?? nil
        let headers = request.allHTTPHeaderFields ?? [:]
        var message: String = "HTTP \(httpMethod) request: → \(baseURL)"
        if !headers.isEmpty {
            message += "\n  + Headers: \(headers)"
        }
        
        if let body = request.httpBody {
            message += "\n  + Body: \(Data.bodyToString(body: body))"
        }
        Debug.message(message)
    }
    
    static func logHTTPResponse(response: URLResponse?, data: Data?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        let urlString = httpResponse?.url?.absoluteString ?? nil
        let statusCode = httpResponse?.statusCode ?? 0
        let headers = httpResponse?.stringifyHeaders ?? [:]
        var message = "HTTP \(statusCode) response: ← \(urlString)"
        message += "\n  + Headers: \(headers)"
        message += "\n  + Data: \(Data.bodyToString(body: data))"
        if let error = error {
            message += "\n  + Error: \(error)"
        }
        
        Debug.message(message)
    }
}
