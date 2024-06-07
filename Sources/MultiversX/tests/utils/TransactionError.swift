#if !WASM

public enum TransactionError: Error, Equatable {
    case userError(message: String)
    
    var message: String {
        switch self {
        case .userError(let message):
            return message
        }
    }
}

#endif
