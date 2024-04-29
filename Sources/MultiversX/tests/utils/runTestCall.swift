#if !WASM
import Foundation

public func runTestCall<T>(
    contractAddress: String,
    endpointName: String,
    hexEncodedArgs: [String],
    operation: () -> T
) -> T {
    return operation()
}

#endif
