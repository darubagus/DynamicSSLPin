//
//  NetworkError.swift
//  
//
//  Created by Daru Bagus Dananjaya on 03/07/23.
//

import Foundation

public enum NetworkError: Error {
    case internalError(message: String)
    case invalidHTTPResponse(statusCode: Int)
    case nilResponseData
    
    case decodingError(DecodingError)
    case encodingError(EncodingError)
    case unexpectedError(Error)
    case serverError(statusCode: Int, payload: Data?)
    case invalidURL
}
