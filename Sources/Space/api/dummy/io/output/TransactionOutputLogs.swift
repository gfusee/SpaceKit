#if !WASM
import Foundation

/// Human readable version of TransactionOutputLogRaw
public struct TransactionOutputLog: Equatable {
    let topics: [String]
    let data: String
    
    public init(topics: [String], data: String) {
        self.topics = topics
        self.data = data
    }
}

package struct TransactionOutputLogRaw {
    
    let topics: [Data]
    let data: Data
    
    package func getReadable() -> TransactionOutputLog {
        TransactionOutputLog(
            topics: self.topics.map { $0.hexEncodedString() },
            data: self.data.hexEncodedString()
        )
    }
}
#endif
