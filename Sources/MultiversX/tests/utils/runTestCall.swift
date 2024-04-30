#if !WASM
import Foundation

public func runTestCall<T>(
    contractAddress: String,
    endpointName: String,
    hexEncodedArgs: [String],
    operation: () -> T
) -> T {
    API.lock.lock()
    
    API.currentContractAddress = contractAddress
    let result = operation()
    API.currentContractAddress = nil
    
    API.lock.unlock()
    
    return result
}

#endif
