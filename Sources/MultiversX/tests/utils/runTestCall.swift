#if !WASM
import Foundation

public func runTestCall<each InputArg: NestedEncode & NestedDecode, ReturnType: TopEncode & TopDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    callerAddress: String? = nil,
    operation: @escaping (repeat each InputArg) -> ReturnType
) throws(TransactionError) -> ReturnType {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsBuffer = MXBuffer()
    for value in repeat each args {
        value.depEncode(dest: &concatenatedInputArgsBuffer)
    }
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    var bytesData: [UInt8] = []
    let transactionInput = getTransactionInput(
        contractAddress: contractAddress,
        callerAddress: callerAddress
    )
    
    try API.runTransactions(transactionInput: transactionInput) {
        var injectedInputBuffer = BufferNestedDecodeInput(buffer: MXBuffer(data: concatenatedInputArgsBufferBytes))
        
        let result = operation(repeat (each InputArg)(depDecode: &injectedInputBuffer))
        
        var bytesDataBuffer = MXBuffer()
        result.topEncode(output: &bytesDataBuffer)
        bytesData = bytesDataBuffer.toBytes() // We have to extract the bytes from the transaction context...
    }
    
    let extractedResultBuffer = MXBuffer(data: bytesData) // ...and reinject it in the root context
    let extractedResult = ReturnType(topDecode: extractedResultBuffer)
    
    return extractedResult
}

public func runTestCall<each InputArg: NestedEncode & NestedDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    callerAddress: String? = nil,
    operation: @escaping (repeat each InputArg) -> Void
) throws(TransactionError) {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsBuffer = MXBuffer()
    for value in repeat each args {
        value.depEncode(dest: &concatenatedInputArgsBuffer)
    }
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    let transactionInput = getTransactionInput(
        contractAddress: contractAddress,
        callerAddress: callerAddress
    )
    
    try API.runTransactions(transactionInput: transactionInput) {
        var injectedInputBuffer = BufferNestedDecodeInput(buffer: MXBuffer(data: concatenatedInputArgsBufferBytes))
        
        operation(repeat (each InputArg)(depDecode: &injectedInputBuffer))
    }
}

private func getTransactionInput(
    contractAddress: String,
    callerAddress: String?
) -> TransactionInput {
    let callerAddress = callerAddress ?? contractAddress
    
    return TransactionInput(
        contractAddress: contractAddress.toAddressData(),
        callerAddress: callerAddress.toAddressData()
    )
}

#endif
