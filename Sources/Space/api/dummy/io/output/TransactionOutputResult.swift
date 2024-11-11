#if !WASM
import Foundation

public struct TransactionOutputResult {
    public let contractAddress: Data
    public var results: [Data]
}
#endif
