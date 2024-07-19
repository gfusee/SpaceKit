#if !WASM
import Foundation
import BigInt

package struct TransactionInput {
    package struct EsdtPayment {
        let tokenIdentifier: Data
        let nonce: UInt64
        let amount: BigInt
    }

    let contractAddress: Data
    let callerAddress: Data
    let egldValue: BigInt
    let esdtValue: [EsdtPayment]
}
#endif
