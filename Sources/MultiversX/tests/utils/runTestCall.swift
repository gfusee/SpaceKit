#if !WASM
import Foundation

public func runTestCall<each InputArg: NestedEncode & NestedDecode, ReturnType: TopEncode & TopDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    operation: (repeat each InputArg) -> ReturnType
) -> ReturnType {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsBuffer = MXBuffer()
    for value in repeat each args {
        value.depEncode(dest: &concatenatedInputArgsBuffer)
    }
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    API.pushNewContainer(contractAddress: contractAddress)
    
    var injectedInputBuffer = BufferNestedDecodeInput(buffer: MXBuffer(data: concatenatedInputArgsBufferBytes))
    
    let result = operation(repeat (each InputArg).depDecode(input: &injectedInputBuffer))
    
    // Popping the container makes the handles invalid.
    // Thus, we have to extract the data out of the container before popping it.
    var bytesDataBuffer = MXBuffer()
    result.topEncode(output: &bytesDataBuffer)
    let bytesData = bytesDataBuffer.toBytes()
    
    API.popContainer()
    
    let extractedResultBuffer = MXBuffer(data: bytesData)
    let extractedResult = ReturnType.topDecode(input: extractedResultBuffer)
    
    return extractedResult
}

public func runTestCall<each InputArg: NestedEncode & NestedDecode>(
    contractAddress: String,
    endpointName: String,
    args: (repeat each InputArg),
    operation: (repeat each InputArg) -> Void
) {
    // Pushing a container makes the previous handles invalid.
    // Thus, we have to inject the data into the new container.
    var concatenatedInputArgsBuffer = MXBuffer()
    for value in repeat each args {
        value.depEncode(dest: &concatenatedInputArgsBuffer)
    }
    let concatenatedInputArgsBufferBytes = concatenatedInputArgsBuffer.toBytes()
    
    API.pushNewContainer(contractAddress: contractAddress)
    
    var injectedInputBuffer = BufferNestedDecodeInput(buffer: MXBuffer(data: concatenatedInputArgsBufferBytes))
    
    operation(repeat (each InputArg).depDecode(input: &injectedInputBuffer))
    
    API.popContainer()
}

#endif
