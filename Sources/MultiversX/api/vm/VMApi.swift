#if WASM

// MARK: Buffer-related OPCODES
@_extern(wasm, module: "env", name: "mBufferSetBytes")
@_extern(c)
func mBufferSetBytes(mBufferHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferSetByteSlice")
@_extern(c)
func mBufferSetByteSlice(
    mBufferHandle: Int32,
    startingPosition: Int32,
    dataLength: Int32,
    dataOffset: UnsafeRawPointer
) -> Int32

@_extern(wasm, module: "env", name: "mBufferAppendBytes")
@_extern(c)
func mBufferAppendBytes(accumulatorHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferCopyByteSlice")
@_extern(c)
func mBufferCopyByteSlice(
        sourceHandle: Int32,
        startingPosition: Int32,
        sliceLength: Int32,
        destinationHandle: Int32
) -> Int32;

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

@_extern(wasm, module: "env", name: "bigIntIsInt64")
@_extern(c)
func bigIntIsInt64(reference: Int32) -> Int32

@_extern(wasm, module: "env", name: "bigIntGetInt64")
@_extern(c)
func bigIntGetInt64(reference: Int32) -> Int64

@_extern(wasm, module: "env", name: "bigIntToString")
@_extern(c)
func bigIntToString(bigIntHandle: Int32, destHandle: Int32)

@_extern(wasm, module: "env", name: "bigIntCmp")
@_extern(c)
func bigIntCmp(x: Int32, y: Int32) -> Int32

@_extern(wasm, module: "env", name: "bigIntAdd")
@_extern(c)
func bigIntAdd(dest: Int32, x: Int32, y: Int32)

@_extern(wasm, module: "env", name: "bigIntSub")
@_extern(c)
func bigIntSub(dest: Int32, x: Int32, y: Int32)

@_extern(wasm, module: "env", name: "bigIntMul")
@_extern(c)
func bigIntMul(dest: Int32, x: Int32, y: Int32)

@_extern(wasm, module: "env", name: "bigIntDiv")
@_extern(c)
func bigIntDiv(dest: Int32, x: Int32, y: Int32)

@_extern(wasm, module: "env", name: "bigIntMod")
@_extern(c)
func bigIntMod(dest: Int32, x: Int32, y: Int32)

@_extern(wasm, module: "env", name: "mBufferToBigIntUnsigned")
@_extern(c)
func mBufferToBigIntUnsigned(mBufferHandle: Int32, bigIntHandle: Int32) -> Int32

// MARK: Storage-related OPCODES

@_extern(wasm, module: "env", name: "mBufferStorageStore")
@_extern(c)
func mBufferStorageStore(keyHandle: Int32, mBufferHandle: Int32) -> Int32

@_extern(wasm, module: "env", name: "mBufferStorageLoad")
@_extern(c)
func mBufferStorageLoad(keyHandle: Int32, mBufferHandle: Int32) -> Int32

// MARK: Endpoint arguments-related OPCODES

@_extern(wasm, module: "env", name: "getNumArguments")
@_extern(c)
func getNumArguments() -> Int32

@_extern(wasm, module: "env", name: "mBufferGetArgument")
@_extern(c)
func mBufferGetArgument(argId: Int32, mBufferHandle: Int32) -> Int32;

// MARK: Blockchain-related OPCODES

@_extern(wasm, module: "env", name: "managedSCAddress")
@_extern(c)
func managedSCAddress(resultHandle: Int32)

@_extern(wasm, module: "env", name: "getBlockTimestamp")
@_extern(c)
func getBlockTimestamp() -> Int64

// MARK: CallValue-related OPCODES
@_extern(wasm, module: "env", name: "bigIntGetCallValue")
@_extern(c)
func bigIntGetCallValue(dest: Int32)

// MARK: Send-related OPCODES
@_extern(wasm, module: "env", name: "managedMultiTransferESDTNFTExecute")
@_extern(c)
func managedMultiTransferESDTNFTExecute(
    dstHandle: Int32,
    tokenTransfersHandle: Int32,
    gasLimit: Int64,
    functionHandle: Int32,
    argumentsHandle: Int32
) -> Int32

@_extern(wasm, module: "env", name: "managedTransferValueExecute")
@_extern(c)
func managedTransferValueExecute(
    dstHandle: Int32,
    valueHandle: Int32,
    gasLimit: Int64,
    functionHandle: Int32,
    argumentsHandle: Int32
) -> Int32

// MARK: Error-related OPCODES

@_extern(wasm, module: "env", name: "managedSignalError")
@_extern(c)
func managedSignalError(messageHandle: Int32)

struct VMApi {}

// MARK: BufferApi Implementation

extension VMApi: BufferApiProtocol {
    mutating func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32 {
        return mBufferSetBytes(mBufferHandle: handle, byte_ptr: bytePtr, byte_len: byteLen)
    }
    
    mutating func mBufferSetByteSlice(
        mBufferHandle: Int32,
        startingPosition: Int32,
        dataLength: Int32,
        dataOffset: UnsafeRawPointer
    ) -> Int32 {
        return MultiversX.mBufferSetByteSlice(
            mBufferHandle: mBufferHandle,
            startingPosition: startingPosition,
            dataLength: dataLength,
            dataOffset: dataOffset
        )
    }
    
    mutating func mBufferAppendBytes(accumulatorHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32 {
        return MultiversX.mBufferAppendBytes(
            accumulatorHandle: accumulatorHandle,
            byte_ptr: byte_ptr,
            byte_len: byte_len
        )
    }
    
    mutating func bufferCopyByteSlice(
        sourceHandle: Int32,
        startingPosition: Int32,
        sliceLength: Int32,
        destinationHandle: Int32
    ) -> Int32 {
        return mBufferCopyByteSlice(
            sourceHandle: sourceHandle,
            startingPosition: startingPosition,
            sliceLength: sliceLength,
            destinationHandle: destinationHandle
        )
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
    
    mutating func bufferToBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        return mBufferToBigIntUnsigned(mBufferHandle: bufferHandle, bigIntHandle: bigIntHandle)
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
    mutating func bigIntSetInt64(destination: Int32, value: Int64) {
        MultiversX.bigIntSetInt64(destination: destination, value: value)
    }
    
    mutating func bigIntIsInt64(reference: Int32) -> Int32 {
        MultiversX.bigIntIsInt64(reference: reference)
    }
    
    mutating func bigIntGetInt64Unsafe(reference: Int32) -> Int64 {
        MultiversX.bigIntGetInt64(reference: reference)
    }

    mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        bigIntToString(bigIntHandle: bigIntHandle, destHandle: destHandle)
    }
    
    mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        return bigIntCmp(x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        MultiversX.bigIntAdd(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        MultiversX.bigIntSub(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        MultiversX.bigIntMul(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        MultiversX.bigIntDiv(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        MultiversX.bigIntMod(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    public mutating func bigIntToString(bigIntHandle: Int32, destHandle: Int32) {
        MultiversX.bigIntToString(bigIntHandle: bigIntHandle, destHandle: destHandle)
    }
}

extension VMApi: StorageApiProtocol {
    mutating func bufferStorageLoad(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        return mBufferStorageLoad(keyHandle: keyHandle, mBufferHandle: bufferHandle)
    }
    
    mutating func bufferStorageStore(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        return mBufferStorageStore(keyHandle: keyHandle, mBufferHandle: bufferHandle)
    }
}

extension VMApi: EndpointApiProtocol {
    mutating func getNumArguments() -> Int32 {
        return MultiversX.getNumArguments()
    }
    
    mutating func bufferGetArgument(argId: Int32, bufferHandle: Int32) -> Int32 {
        return MultiversX.mBufferGetArgument(argId: argId, mBufferHandle: bufferHandle)
    }
}

// MARK: BlockchainApiProtocol implementation

extension VMApi: BlockchainApiProtocol {
    mutating func managedSCAddress(resultHandle: Int32) {
        return MultiversX.managedSCAddress(resultHandle: resultHandle)
    }
    
    mutating func getBlockTimestamp() -> Int64 {
        return MultiversX.getBlockTimestamp()
    }
}

// MARK: CallValueApiProtocol Implementation

extension VMApi: CallValueApiProtocol {
    mutating func bigIntGetCallValue(dest: Int32) {
        return MultiversX.bigIntGetCallValue(dest: dest)
    }
}

// MARK: SendApiProtocol Implementation

extension VMApi: SendApiProtocol {
    mutating func managedMultiTransferESDTNFTExecute(
        dstHandle: Int32,
        tokenTransfersHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32 {
        return MultiversX.managedMultiTransferESDTNFTExecute(
            dstHandle: dstHandle,
            tokenTransfersHandle: tokenTransfersHandle,
            gasLimit: gasLimit,
            functionHandle: functionHandle,
            argumentsHandle: argumentsHandle
        )
    }
    
    mutating func managedTransferValueExecute(
        dstHandle: Int32,
        valueHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32 {
        return MultiversX.managedTransferValueExecute(
            dstHandle: dstHandle,
            valueHandle: valueHandle,
            gasLimit: gasLimit,
            functionHandle: functionHandle,
            argumentsHandle: argumentsHandle
        )
    }
}

// MARK: ErrorApiProtocol implementation

extension VMApi: ErrorApiProtocol {
    mutating func managedSignalError(messageHandle: Int32) -> Never {
        MultiversX.managedSignalError(messageHandle: messageHandle)
        fatalError()
    }
}

#endif
