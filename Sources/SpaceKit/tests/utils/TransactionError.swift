#if !WASM
import Foundation

public enum TransactionError: LocalizedError, Equatable {
    case userError(message: String)
    case executionFailed(reason: String)
    case worldError(message: String)
    
    var message: String {
        switch self {
        case .userError(let message):
            return message
        case .executionFailed(let reason):
            return reason
        case .worldError(let message):
            return message
        }
    }
    
    public var errorDescription: String? {
        self.debugDescription
    }
    
    var code: UInt32 {
        switch self {
        case .userError(_):
            4
        case .executionFailed(_):
            10
        case .worldError(_):
            100
        }
    }
    
    var isUserError: Bool {
        switch self {
        case .userError(_):
            true
        case .executionFailed(_):
            false
        case .worldError(_):
            false
        }
    }
}

extension TransactionError: CustomStringConvertible {
    public var description: String {
        "Code: \(self.code), Description: \(self.message)"
    }
}

extension TransactionError: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Code: \(self.code), Description: \(self.message)"
    }
}

#endif
