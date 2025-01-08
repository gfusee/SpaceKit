#if !WASM

public enum TransactionError: Error, Equatable {
    case userError(message: String)
    case executionFailed(reason: String)
    case worldError(message: String)
    
    var message: String {
        switch self {
        case .userError(let message):
            return message
        case .executionFailed(_):
            return "execution failed"
        case .worldError(let message):
            return message
        }
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

#endif
