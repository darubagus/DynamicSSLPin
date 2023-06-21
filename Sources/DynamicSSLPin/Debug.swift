//
//  File.swift
//  
//
//  Created by Daru Bagus Dananjaya on 20/06/23.
//

import Foundation

public class debug {
    public static func fatalError(_ message: @autoclosure ()->String) -> Never {
        Swift.fatalError(message(), file: "", line: 1)
    }
}
