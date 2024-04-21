let BUFFER_API = BufferApiVmImpl()
let BIGINT_API = BigIntApiVmImpl()

var nextHandle: Int32 = -100
func getNextHandle() -> Int32 {
    let currentHandle = nextHandle
    nextHandle -= 1

    return currentHandle
}
