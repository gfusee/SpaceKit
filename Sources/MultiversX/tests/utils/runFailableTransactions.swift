#if !WASM

import Foundation

public func runFailableTransactions(transactions: @escaping () -> Void) throws(TransactionError) {
    let semaphore = DispatchSemaphore(value: 0)
    
    Task<Void, Never> {
        await withTaskCancellationHandler {
            transactions()
            semaphore.signal()
        } onCancel: {
            semaphore.signal()
        }
    }
    
    semaphore.wait()
    
    if let errorMessage = API.getCurrentContainer().errorMessage {
        throw TransactionError.userError(message: errorMessage)
    }
}

#endif
