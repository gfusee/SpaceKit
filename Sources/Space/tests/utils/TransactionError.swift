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
}

#endif
