//
//  Data.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

extension Data {
    public static func getRandomData(length: Int) -> Data {
        var data = Data(count: length)
        let res = data.withUnsafeMutableBytes { (ptr) -> Int32 in
            if let rawPointer = ptr.baseAddress {
                return SecRandomCopyBytes(kSecRandomDefault, length, rawPointer)
            }
            return errSecAllocate
        }
        guard res == errSecSuccess else {
            Debug.fatalError("Can't generate random")
        }
        return data
    }
}
