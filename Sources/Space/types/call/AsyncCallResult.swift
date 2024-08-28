let SAME_SHARD_SUCCESS_CODE: UInt32 = 0
let CROSS_SHARD_SUCCESS_CODE: UInt32 = 0x00006f6b // "ok"

public struct AsyncCallError {
    public let errorCode: UInt32
    public let errorMessage: MXBuffer
}

public enum AsyncCallResult<T: TopDecodeMulti> {
    case success(T)
    case error(AsyncCallError)
}

extension AsyncCallResult: TopDecodeMulti {
    public init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        // TODO: add tests
        let errorCode = UInt32(topDecodeMulti: &input)
        if errorCode == SAME_SHARD_SUCCESS_CODE || errorCode == CROSS_SHARD_SUCCESS_CODE {
            self = .success(T(topDecodeMulti: &input))
        } else {
            let errorMessage = if input.hasNext() {
                input.nextValueInput()
            } else { // The absence of error message seems to be possible and due to a bug at the protocol level
                MXBuffer()
            }
            
            self = .error(
                AsyncCallError(
                    errorCode: errorCode,
                    errorMessage: errorMessage
                )
            )
        }
    }
}
