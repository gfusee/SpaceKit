#if !WASM
import Foundation

public class TransactionOutput {
    package var results: [TransactionOutputResult] = []
    package private(set) var esdtTransfersPerformed: [(Data, Data, TransactionInput.EsdtPayment)] = [] // (from, to, payment)
    package private(set) var logs: [TransactionOutputLogRaw] = []
    
    public init() {}
    
    package func copied() -> TransactionOutput {
        let output = TransactionOutput()
        output.results = results
        output.esdtTransfersPerformed = esdtTransfersPerformed
        output.logs = logs
        
        return output
    }
    
    package func merge(output: TransactionOutput) {
        self.results.append(contentsOf: output.results)
        self.esdtTransfersPerformed.append(contentsOf: output.esdtTransfersPerformed)
        self.logs.append(contentsOf: output.logs)
    }
    
    package func writeLog(log: TransactionOutputLogRaw) {
        self.logs.append(log)
    }
    
    package func registerEsdtTransfer(
        from: Data,
        to: Data,
        transfer: TransactionInput.EsdtPayment
    ) {
        self.esdtTransfersPerformed.append(
            (from, to, transfer)
        )
    }
    
    public func getLogs() -> [TransactionOutputLog] {
        return self.logs.map { $0.getReadable() }
    }
}
#endif
