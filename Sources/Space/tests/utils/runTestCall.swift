#if !WASM
import Foundation
import BigInt

public func runTestCall<each InputArg: TopEncodeMulti & TopDecodeMulti, ReturnType: TopEncodeMulti & TopDecodeMulti>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    transactionInput: TransactionInput,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping (repeat each InputArg) -> ReturnType
) throws(TransactionError) -> ReturnType {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsBuffers = Vector<Buffer>() // We don't want the same encoding as Vector, since we will dep decode multiple types, the same way as a struct
    for value in repeat each args {
        value.multiEncode(output: &concatenatedInputArgsBuffers)
    }
    
    var concatenatedInputArgsBuffersBytes: [[UInt8]] = []
    concatenatedInputArgsBuffers.forEach { value in
        concatenatedInputArgsBuffersBytes.append(value.toBytes())
    }
    
    var bytesData: [[UInt8]] = []
    
    try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            var injectedInputBuffers: Vector<Buffer> = Vector()
            for bytes in concatenatedInputArgsBuffersBytes {
                injectedInputBuffers = injectedInputBuffers.appended(Buffer(data: bytes))
            }
            
            let result = operation(repeat (each InputArg)(topDecodeMulti: &injectedInputBuffers))
            
            var bytesDataBuffers = Vector<Buffer>()
            result.multiEncode(output: &bytesDataBuffers)
            
            bytesDataBuffers.forEach { value in
                bytesData.append(value.toBytes()) // We have to extract the bytes from the transaction context...
            }
        }
    )
    
    var extractedResultBuffers: Vector<Buffer> = Vector() // ...and reinject it in the root context
    for bytes in bytesData {
        extractedResultBuffers = extractedResultBuffers.appended(Buffer(data: bytes))
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
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsBuffers = Vector<Buffer>() // We don't want the same encoding as Vector, since we will dep decode multiple types, the same way as a struct
    for value in repeat each args {
        value.multiEncode(output: &concatenatedInputArgsBuffers)
    }
    
    var concatenatedInputArgsBuffersBytes: [[UInt8]] = []
    concatenatedInputArgsBuffers.forEach { value in
        concatenatedInputArgsBuffersBytes.append(value.toBytes())
    }
    
    try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput,
        operations: UncheckedClosure {
            var injectedInputBuffers: Vector<Buffer> = Vector()
            for bytes in concatenatedInputArgsBuffersBytes {
                injectedInputBuffers = injectedInputBuffers.appended(Buffer(data: bytes))
            }
            
            operation(repeat (each InputArg)(topDecodeMulti: &injectedInputBuffers))
        }
    )
}


#endif
