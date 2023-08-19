//
//  Debugger.swift
//  DynamicSSLPin-TATests
//
//  Created by Daru Bagus Dananjaya on 19/08/23.
//

import Foundation

public class Debug {
    public static func fatalError(_ message: @autoclosure ()->String) -> Never {
        Swift.fatalError(message(), file: "", line: 1)
    }
    
    public static func message(_ message: @autoclosure () -> String) {
        Swift.print(message())
    }
}
