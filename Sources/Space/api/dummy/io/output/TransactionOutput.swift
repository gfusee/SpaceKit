#if !WASM
import Foundation

public class TransactionOutput {
    package var results: [TransactionOutputResult] = []
    package var logs: [TransactionOutputLogRaw] = []
    
    public init() {}
    
    package func copied() -> TransactionOutput {
        let output = TransactionOutput()
        output.results = results
        output.logs = logs
        
        return output
    }
    
    package func merge(output: TransactionOutput) {
        self.results.append(contentsOf: output.results)
        self.logs.append(contentsOf: output.logs)
    }
    
    package func writeLog(log: TransactionOutputLogRaw) {
        self.logs.append(log)
    }
    
    public func getLogs() -> [TransactionOutputLog] {
        return self.logs.map { $0.getReadable() }
    }
}
#endif
