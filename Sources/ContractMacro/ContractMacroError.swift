//
//  File.swift
//  
//
//  Created by Quentin Diebold on 23/04/2024.
//

import Foundation

enum ContractMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    case onlyOneConvenienceInitAllowed
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@Contract can only be applied to a structure."
        case .onlyOneConvenienceInitAllowed: return "Only one or zero convenience initializer is allowed in a structure marked @Contract."
        }
    }
}
