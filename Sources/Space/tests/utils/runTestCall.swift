#if !WASM
import Foundation
import BigInt

public func runTestCall<each InputArg: TopEncodeMulti & TopDecodeMulti, ReturnType: TopEncodeMulti & TopDecodeMulti>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping (repeat each InputArg) -> Void
) throws(TransactionError) -> ReturnType {
    let results = try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            operation(repeat each args)
        }
    )
    
    var extractedResultBuffers: Vector<Buffer> = Vector()
    
    for bytes in results {
        extractedResultBuffers = extractedResultBuffers.appended(Buffer(data: Array(bytes)))
    }
    
    let extractedResult = ReturnType(topDecodeMulti: &extractedResultBuffers)
    
    return extractedResult
}

public func runTestCall<each InputArg: TopEncodeMulti & TopDecodeMulti>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping (repeat each InputArg) -> Void
) throws(TransactionError) {
    let _ = try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            operation(repeat each args)
        }
    )
}


#endif
