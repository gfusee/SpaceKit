#if !WASM

public enum TransactionError: Error, Equatable {
    case userError(message: String)
}

#endif
