#if !WASM
import Foundation
import BigInt

public func runTestCall<ReturnType: TopEncodeMulti & TopDecodeMulti>(
    contractAddress: String,
    endpointName: String,
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping () -> Void
) throws(TransactionError) -> ReturnType {
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
    
    let extractedResult = ReturnType(topDecodeMulti: &extractedResultBuffers)
    
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
