#if !WASM
import Foundation

package struct AsyncCallInput {
    let function: Data
    let isCallback: Bool
    let input: TransactionInput
}
#endif
