#if !WASM

struct BigIntApiMockImpl {}

extension BigIntApiMockImpl: BigIntApiProtocol {
    func bigIntSetInt64Value(destination: Int32, value: Int64) {

    }

    func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {

    }
}

#endif
