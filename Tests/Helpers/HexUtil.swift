//
//  HexUtil.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

extension Data {
    private static let toHexTable: [Character] = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]

    static func fromHex(_ string: String) -> Data? {
        var result = Data()
        result.reserveCapacity(string.count / 2 + 1)
        var upperHalf: UInt32 = 0
        var count = string.count & 1
        for ch in string.unicodeScalars {
            if (count & 1) == 0 {
                upperHalf = chToByte(ch)
                if upperHalf == 0xff {
                    return nil
                }
            } else {
                let lowerHalf = chToByte(ch)
                if lowerHalf == 0xff {
                    return nil
                }
                result.append(UInt8(upperHalf << 4 | lowerHalf))
            }
            count += 1
        }
        return result
    }

    private static func chToByte(_ char: UnicodeScalar) -> UInt32 {
        if char >= "0" && char <= "9" {
            return char.value - 48
        }
        if char >= "A" && char <= "F" {
            return char.value - 65 + 10
        }
        if char >= "a" && char <= "f" {
            return char.value - 97 + 10
        }
        
        // If character is invalid, returns 0xFF
        return 0xff
    }
    
    var toHex: String {
        var result = ""
        result.reserveCapacity(self.count * 2)
        for byte in self {
            let byteAsUInt = Int(byte)
            result.append(Data.toHexTable[byteAsUInt >> 4])
            result.append(Data.toHexTable[byteAsUInt & 15])
        }
        return result
    }
    
}
