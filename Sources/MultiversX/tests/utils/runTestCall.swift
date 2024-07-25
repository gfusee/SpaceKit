#if !WASM
import Foundation
import BigInt

public func runTestCall<each InputArg: TopEncode & NestedEncode & NestedDecode, ReturnType: TopEncode & TopDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    callerAddress: String? = nil,
    egldValue: BigUint = 0,
    esdtValue: MXArray<TokenPayment>,
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping (repeat each InputArg) -> ReturnType
) throws(TransactionError) -> ReturnType {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsArray: MXArray<MXBuffer> = MXArray()
    var concatenatedInputArgsBuffer =  MXBuffer() // We don't want the same encoding as MXArray, since we will dep decode multiple types, the same way as a struct
    for value in repeat each args {
        var argTopEncodedBuffer = MXBuffer()
        var argNestedEncodedBuffer = MXBuffer()
        value.topEncode(output: &argTopEncodedBuffer)
        value.depEncode(dest: &argNestedEncodedBuffer)
        
        concatenatedInputArgsArray = concatenatedInputArgsArray.appended(argTopEncodedBuffer)
        concatenatedInputArgsBuffer = concatenatedInputArgsBuffer + argNestedEncodedBuffer
    }
    
    var concatenatedInputArgsTopEncoded = MXBuffer()
    concatenatedInputArgsArray.topEncode(output: &concatenatedInputArgsTopEncoded)
    
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    var bytesData: [UInt8] = []
    let transactionInput = getTransactionInput(
        contractAddress: contractAddress,
        callerAddress: callerAddress,
        egldValue: egldValue,
        esdtValue: esdtValue,
        arguments: concatenatedInputArgsArray
    )
    
    try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput
    ) {
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

public func runTestCall<each InputArg: TopEncode & NestedEncode & NestedDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    callerAddress: String? = nil,
    egldValue: BigUint = 0,
    esdtValue: MXArray<TokenPayment> = [],
    transactionOutput: TransactionOutput = TransactionOutput(),
    operation: @escaping (repeat each InputArg) -> Void
) throws(TransactionError) {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsArray: MXArray<MXBuffer> = MXArray()
    var concatenatedInputArgsBuffer =  MXBuffer() // We don't want the same encoding as MXArray, since we will dep decode multiple types, the same way as a struct
    for value in repeat each args {
        var argTopEncodedBuffer = MXBuffer()
        var argNestedEncodedBuffer = MXBuffer()
        value.topEncode(output: &argTopEncodedBuffer)
        value.depEncode(dest: &argNestedEncodedBuffer)
        
        concatenatedInputArgsArray = concatenatedInputArgsArray.appended(argTopEncodedBuffer)
        concatenatedInputArgsBuffer = concatenatedInputArgsBuffer + argNestedEncodedBuffer
    }
    
    var concatenatedInputArgsTopEncoded = MXBuffer()
    concatenatedInputArgsArray.topEncode(output: &concatenatedInputArgsTopEncoded)
    
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    let transactionInput = getTransactionInput(
        contractAddress: contractAddress,
        callerAddress: callerAddress,
        egldValue: egldValue,
        esdtValue: esdtValue,
        arguments: concatenatedInputArgsArray
    )
    
    try API.runTransactions(
        transactionInput: transactionInput,
        transactionOutput: transactionOutput
    ) {
        var injectedInputBuffer = BufferNestedDecodeInput(buffer: MXBuffer(data: concatenatedInputArgsBufferBytes))
        
        operation(repeat (each InputArg)(depDecode: &injectedInputBuffer))
    }
}

private func getTransactionInput(
    contractAddress: String,
    callerAddress: String?,
    egldValue: BigUint,
    esdtValue: MXArray<TokenPayment>,
    arguments: MXArray<MXBuffer>
) -> TransactionInput {
    let callerAddress = callerAddress ?? contractAddress
    var esdtValueArray: [TransactionInput.EsdtPayment] = []

    for transfer in esdtValue {
        esdtValueArray.append(
            TransactionInput.EsdtPayment(
                tokenIdentifier: Data(transfer.tokenIdentifier.toBytes()),
                nonce: transfer.nonce,
                amount: BigInt(bigUint: transfer.amount)
            )
        )
    }
    
    var argumentsData: [Data] = []
    
    for arg in arguments {
        argumentsData.append(Data(arg.toBytes()))
    }
    
    return TransactionInput(
        contractAddress: contractAddress.toAddressData(),
        callerAddress: callerAddress.toAddressData(),
        egldValue: BigInt(bigUint: egldValue),
        esdtValue: esdtValueArray,
        arguments: argumentsData
    )
}

#endif
