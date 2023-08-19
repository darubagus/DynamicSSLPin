//
//  JSONUtility.swift
//  
//
//  Created by Daru Bagus Dananjaya on 04/07/23.
//

import Foundation

public class JSONUtility {
    func jsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    func jsonEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
}

