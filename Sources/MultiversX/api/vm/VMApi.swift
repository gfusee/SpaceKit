#if WASM

// MARK: Buffer-related OPCODES
@_extern(wasm, module: "env", name: "mBufferSetBytes")
@_extern(c)
func mBufferSetBytes(mBufferHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferAppend")
@_extern(c)
func mBufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferFinish")
@_extern(c)
func mBufferFinish(mBufferHandle: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferGetLength")
@_extern(c)
func mBufferGetLength(mBufferHandle: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferGetBytes")
@_extern(c)
func mBufferGetBytes(mBufferHandle: Int32, resultOffset: UnsafeRawPointer) -> Int32

@_extern(wasm, module: "env", name: "mBufferFromBigIntUnsigned")
@_extern(c)
func mBufferFromBigIntUnsigned(mBufferHandle: Int32, bigIntHandle: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferEq")
@_extern(c)
func mBufferEq(handle1: Int32, handle2: Int32) -> Int32

// MARK: BigInt-related OPCODES

@_extern(wasm, module: "env", name: "bigIntSetInt64")
@_extern(c)
func bigIntSetInt64(destination: Int32, value: Int64)

@_extern(wasm, module: "env", name: "bigIntToString")
@_extern(c)
func bigIntToString(bigIntHandle: Int32, destHandle: Int32)

@_extern(wasm, module: "env", name: "bigIntCmp")
@_extern(c)
func bigIntCmp(x: Int32, y: Int32) -> Int32

struct VMApi {}

// MARK: BufferApi Implementation

extension VMApi: BufferApiProtocol {
    mutating func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32 {
        return mBufferSetBytes(mBufferHandle: handle, byte_ptr: bytePtr, byte_len: byteLen)
    }

    mutating func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32 {
        return mBufferAppend(accumulatorHandle: accumulatorHandle, dataHandle: dataHandle)
    }
    
    func bufferGetLength(handle: Int32) -> Int32 {
        return mBufferGetLength(mBufferHandle: handle)
    }
    
    func bufferGetBytes(handle: Int32, resultPointer: UnsafeRawPointer) -> Int32 {
        return mBufferGetBytes(mBufferHandle: handle, resultOffset: resultPointer)
    }
    
    mutating func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        return mBufferFromBigIntUnsigned(mBufferHandle: bufferHandle, bigIntHandle: bigIntHandle)
    }

    mutating func bufferFinish(handle: Int32) -> Int32 {
        return mBufferFinish(mBufferHandle: handle)
    }
    
    mutating func bufferEqual(handle1: Int32, handle2: Int32) -> Int32 {
        return mBufferEq(handle1: handle1, handle2: handle2)
    }
}

// MARK: BigIntApi Implementation

extension VMApi: BigIntApiProtocol {
    mutating func bigIntSetInt64Value(destination: Int32, value: Int64) {
        bigIntSetInt64(destination: destination, value: value)
    }

    mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        bigIntToString(bigIntHandle: bigIntHandle, destHandle: destHandle)
    }
    
    mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        return bigIntCmp(x: lhsHandle, y: rhsHandle)
    }
}

#endif
