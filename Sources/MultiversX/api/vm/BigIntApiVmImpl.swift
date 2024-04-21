@_extern(wasm, module: "env", name: "bigIntSetInt64")
@_extern(c)
func bigIntSetInt64(destination: Int32, value: Int64)

@_extern(wasm, module: "env", name: "bigIntToString")
@_extern(c)
func bigIntToString(bigIntHandle: Int32, destHandle: Int32)

struct BigIntApiVmImpl {}

extension BigIntApiVmImpl: BigIntApiProtocol {
    func bigIntSetInt64Value(destination: Int32, value: Int64) {
        bigIntSetInt64(destination: destination, value: value)
    }

    func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        bigIntToString(bigIntHandle: bigIntHandle, destHandle: destHandle)
    }
}
