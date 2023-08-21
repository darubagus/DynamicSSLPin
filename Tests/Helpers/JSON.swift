//
//  JSON.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
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

extension Encodable {
    
    func toJSON() -> Data {
        let jsonUtil = JSONUtility()
        guard let data = try? jsonUtil.jsonEncoder().encode(self) else {
            Debug.fatalError("Can't serialize JSON")
        }
        return data
    }
}
