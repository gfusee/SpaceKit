#if !WASM
import Foundation

package struct AsyncCallCallbackInput {
    let function: Data
    let args: Data
}

package struct AsyncCallInput {
    let function: Data
    let input: TransactionInput
    let callbackClosure: Data? // != nil means it is a callback execution
    let successCallback: AsyncCallCallbackInput?
    let errorCallback: AsyncCallCallbackInput?
}
#endif
