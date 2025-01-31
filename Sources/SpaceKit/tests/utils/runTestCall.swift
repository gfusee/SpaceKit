#if !WASM
import Foundation
import BigInt

public func runTestCall<ReturnType: TopDecodeMulti>(
    contractAddress: String,
    endpointName: String,
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    for returnType: ReturnType.Type, // So Swift doesn't complain of ReturnType not used in the function signature
    operation: @escaping () -> Void
) throws(TransactionError) -> ReturnType.SwiftVMDecoded {
    let results = try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            operation()
        }
    ).results
    
    var extractedResultBuffers: Vector<Buffer> = Vector()
    
    for bytes in results {
        extractedResultBuffers = extractedResultBuffers.appended(Buffer(data: Array(bytes)))
    }
    
    let extractedResult = ReturnType.fromTopDecodeMultiInput(&extractedResultBuffers)
    
    return extractedResult
}

public func runTestCall(
    contractAddress: String,
    endpointName: String,
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping () -> Void
) throws(TransactionError) {
    let _ = try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            operation()
        }
    )
}


#endif
