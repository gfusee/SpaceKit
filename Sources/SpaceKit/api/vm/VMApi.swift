#if WASM

nonisolated(unsafe) var nextHandle: Int32 = -100

// TODO: /!\ CRITICAL /!\ Handle all possible errors from the Int32 status code. For example substracting two BigUint A - B, where A < B, DOESN'T throw an error in the VM

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

@_extern(wasm, module: "env", name: "managedBufferToHex")
@_extern(c)
func managedBufferToHex(sourceHandle: Int32, destinationHandle: Int32)

@_extern(wasm, module: "env", name: "mBufferSetRandom")
@_extern(c)
func mBufferSetRandom(destinationHandle: Int32, length: Int32) -> Int32

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

@_extern(wasm, module: "env", name: "bigIntTDiv")
@_extern(c)
func bigIntTDiv(dest: Int32, x: Int32, y: Int32)

@_extern(wasm, module: "env", name: "bigIntTMod")
@_extern(c)
func bigIntTMod(dest: Int32, x: Int32, y: Int32)

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

@_extern(wasm, module: "env", name: "managedGetCallbackClosure")
@_extern(c)
func managedGetCallbackClosure(callbackClosureHandle: Int32)

// MARK: Blockchain-related OPCODES

@_extern(wasm, module: "env", name: "managedSCAddress")
@_extern(c)
func managedSCAddress(resultHandle: Int32)

@_extern(wasm, module: "env", name: "getBlockNonce")
@_extern(c)
func getBlockNonce() -> Int64

@_extern(wasm, module: "env", name: "getBlockTimestamp")
@_extern(c)
func getBlockTimestamp() -> Int64

@_extern(wasm, module: "env", name: "getBlockRound")
@_extern(c)
func getBlockRound() -> Int64

@_extern(wasm, module: "env", name: "getBlockEpoch")
@_extern(c)
func getBlockEpoch() -> Int64

@_extern(wasm, module: "env", name: "managedGetBlockRandomSeed")
@_extern(c)
func managedGetBlockRandomSeed(resultHandle: Int32)

@_extern(wasm, module: "env", name: "managedGetOriginalTxHash")
@_extern(c)
func managedGetOriginalTxHash(resultHandle: Int32)

@_extern(wasm, module: "env", name: "bigIntGetExternalBalance")
@_extern(c)
func bigIntGetExternalBalance(address_ptr: UnsafeRawPointer, dest: Int32)

@_extern(wasm, module: "env", name: "bigIntGetESDTExternalBalance")
@_extern(c)
func bigIntGetESDTExternalBalance(
    address_ptr: UnsafeRawPointer,
    tokenIDOffset: UnsafeRawPointer,
    tokenIDLen: Int32,
    nonce: Int64,
    dest: Int32
)

@_extern(wasm, module: "env", name: "getCaller")
@_extern(c)
func getCaller(resultOffset: UnsafeRawPointer)

@_extern(wasm, module: "env", name: "managedOwnerAddress")
@_extern(c)
func managedOwnerAddress(resultHandle: Int32)

@_extern(wasm, module: "env", name: "getGasLeft")
@_extern(c)
func getGasLeft() -> Int64

@_extern(wasm, module: "env", name: "getESDTLocalRoles")
@_extern(c)
func getESDTLocalRoles(tokenhandle: Int32) -> Int64

@_extern(wasm, module: "env", name: "managedGetESDTTokenData")
@_extern(c)
func managedGetESDTTokenData(
    addressHandle: Int32,
    tokenIDHandle: Int32,
    nonce: Int64,
    valueHandle: Int32,
    propertiesHandle: Int32,
    hashHandle: Int32,
    nameHandle: Int32,
    attributesHandle: Int32,
    creatorHandle: Int32,
    royaltiesHandle: Int32,
    urisHandle: Int32
)

@_extern(wasm, module: "env", name: "getShardOfAddress")
@_extern(c)
func getShardOfAddress(address_ptr: UnsafeRawPointer) -> Int32

// MARK: CallValue-related OPCODES
@_extern(wasm, module: "env", name: "bigIntGetCallValue")
@_extern(c)
func bigIntGetCallValue(dest: Int32)

@_extern(wasm, module: "env", name: "managedGetMultiESDTCallValue")
@_extern(c)
func managedGetMultiESDTCallValue(resultHandle: Int32)

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

@_extern(wasm, module: "env", name: "managedExecuteOnDestContext")
@_extern(c)
func managedExecuteOnDestContext(
    gas: Int64,
    addressHandle: Int32,
    valueHandle: Int32,
    functionHandle: Int32,
    argumentsHandle: Int32,
    resultHandle: Int32
) -> Int32

@_extern(wasm, module: "env", name: "managedCreateAsyncCall")
@_extern(c)
func managedCreateAsyncCall(
    dstHandle: Int32,
    valueHandle: Int32,
    functionHandle: Int32,
    argumentsHandle: Int32,
    successOffset: UnsafeRawPointer,
    successLength: Int32,
    errorOffset: UnsafeRawPointer,
    errorLength: Int32,
    gas: Int64,
    extraGasForCallback: Int64,
    callbackClosureHandle: Int32
) -> Int32

@_extern(wasm, module: "env", name: "managedDeployFromSourceContract")
@_extern(c)
func managedDeployFromSourceContract(
    gas: Int64,
    valueHandle: Int32,
    addressHandle: Int32,
    codeMetadataHandle: Int32,
    argumentsHandle: Int32,
    resultAddressHandle: Int32,
    resultHandle: Int32
) -> Int32

@_extern(wasm, module: "env", name: "managedUpgradeFromSourceContract")
@_extern(c)
func managedUpgradeFromSourceContract(
    dstHandle: Int32,
    gas: Int64,
    valueHandle: Int32,
    addressHandle: Int32,
    codeMetadataHandle: Int32,
    argumentsHandle: Int32,
    resultHandle: Int32
)

@_extern(wasm, module: "env", name: "cleanReturnData")
@_extern(c)
func cleanReturnData()

// MARK: Error-related OPCODES

@_extern(wasm, module: "env", name: "managedSignalError")
@_extern(c)
func managedSignalError(messageHandle: Int32)

// MARK: Log-related OPCODES
@_extern(wasm, module: "env", name: "managedWriteLog")
@_extern(c)
func managedWriteLog(topicsHandle: Int32, dataHandle: Int32)

// MARK: Crypto-related OPCODES
@_extern(wasm, module: "env", name: "managedVerifyEd25519")
@_extern(c)
func managedVerifyEd25519(keyHandle: Int32, messageHandle: Int32, sigHandle: Int32) -> Int32

@_extern(wasm, module: "env", name: "managedSha256")
@_extern(c)
func managedSha256(inputHandle: Int32, outputHandle: Int32) -> Int32

struct VMApi {
    
    public func getNextHandle() -> Int32 {
        let currentHandle = nextHandle
        nextHandle -= 1

        return currentHandle
    }
    
}

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
        return SpaceKit.mBufferSetByteSlice(
            mBufferHandle: mBufferHandle,
            startingPosition: startingPosition,
            dataLength: dataLength,
            dataOffset: dataOffset
        )
    }
    
    mutating func mBufferAppendBytes(accumulatorHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32 {
        return SpaceKit.mBufferAppendBytes(
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
    
    mutating func managedBufferToHex(sourceHandle: Int32, destinationHandle: Int32) {
        SpaceKit.managedBufferToHex(sourceHandle: sourceHandle, destinationHandle: destinationHandle)
    }
    
    mutating func mBufferSetRandom(destinationHandle: Int32, length: Int32) -> Int32 {
        return SpaceKit.mBufferSetRandom(destinationHandle: destinationHandle, length: length)
    }
}

// MARK: BigIntApi Implementation

extension VMApi: BigIntApiProtocol {
    mutating func bigIntSetInt64(destination: Int32, value: Int64) {
        SpaceKit.bigIntSetInt64(destination: destination, value: value)
    }
    
    mutating func bigIntIsInt64(reference: Int32) -> Int32 {
        SpaceKit.bigIntIsInt64(reference: reference)
    }
    
    mutating func bigIntGetInt64Unsafe(reference: Int32) -> Int64 {
        SpaceKit.bigIntGetInt64(reference: reference)
    }

    mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        bigIntToString(bigIntHandle: bigIntHandle, destHandle: destHandle)
    }
    
    mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        return bigIntCmp(x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        SpaceKit.bigIntAdd(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        SpaceKit.bigIntSub(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        SpaceKit.bigIntMul(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntTDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        SpaceKit.bigIntTDiv(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    mutating func bigIntTMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        SpaceKit.bigIntTMod(dest: destHandle, x: lhsHandle, y: rhsHandle)
    }
    
    public mutating func bigIntToString(bigIntHandle: Int32, destHandle: Int32) {
        SpaceKit.bigIntToString(bigIntHandle: bigIntHandle, destHandle: destHandle)
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
        return SpaceKit.getNumArguments()
    }
    
    mutating func bufferGetArgument(argId: Int32, bufferHandle: Int32) -> Int32 {
        return SpaceKit.mBufferGetArgument(argId: argId, mBufferHandle: bufferHandle)
    }
    
    mutating func managedGetCallbackClosure(callbackClosureHandle: Int32) {
        return SpaceKit.managedGetCallbackClosure(callbackClosureHandle: callbackClosureHandle)
    }
}

// MARK: BlockchainApiProtocol implementation

extension VMApi: BlockchainApiProtocol {
    mutating func managedSCAddress(resultHandle: Int32) {
        return SpaceKit.managedSCAddress(resultHandle: resultHandle)
    }
    
    mutating func getBlockNonce() -> Int64 {
        return SpaceKit.getBlockNonce()
    }
    
    mutating func getBlockTimestamp() -> Int64 {
        return SpaceKit.getBlockTimestamp()
    }
    
    mutating func getBlockRound() -> Int64 {
        return SpaceKit.getBlockRound()
    }
    
    mutating func getBlockEpoch() -> Int64 {
        return SpaceKit.getBlockEpoch()
    }
    
    mutating func managedGetBlockRandomSeed(resultHandle: Int32) {
        SpaceKit.managedGetBlockRandomSeed(resultHandle: resultHandle)
    }
    
    mutating func managedGetOriginalTxHash(resultHandle: Int32) {
        return SpaceKit.managedGetOriginalTxHash(resultHandle: resultHandle)
    }
    
    mutating func bigIntGetExternalBalance(addressPtr: UnsafeRawPointer, dest: Int32) {
        return SpaceKit.bigIntGetExternalBalance(
            address_ptr: addressPtr,
            dest: dest
        )
    }
    
    mutating func bigIntGetESDTExternalBalance(
        addressPtr: UnsafeRawPointer,
        tokenIDOffset: UnsafeRawPointer,
        tokenIDLen: Int32,
        nonce: Int64,
        dest: Int32
    ) {
        return SpaceKit.bigIntGetESDTExternalBalance(
            address_ptr: addressPtr,
            tokenIDOffset: tokenIDOffset,
            tokenIDLen: tokenIDLen,
            nonce: nonce,
            dest: dest
        )
    }
    
    mutating func getCaller(resultOffset: UnsafeRawPointer) {
        return SpaceKit.getCaller(resultOffset: resultOffset)
    }

    mutating func managedOwnerAddress(resultHandle: Int32) {
        return SpaceKit.managedOwnerAddress(resultHandle: resultHandle)
    }
    
    mutating func getGasLeft() -> Int64 {
        return SpaceKit.getGasLeft()
    }
    
    mutating func getESDTLocalRoles(tokenIdHandle: Int32) -> Int64 {
        return SpaceKit.getESDTLocalRoles(tokenhandle: tokenIdHandle)
    }
    
    mutating func getShardOfAddress(addressPtr: UnsafeRawPointer) -> Int32 {
        return SpaceKit.getShardOfAddress(address_ptr: addressPtr)
    }
    
    mutating func managedGetESDTTokenData(
        addressHandle: Int32,
        tokenIDHandle: Int32,
        nonce: Int64,
        valueHandle: Int32,
        propertiesHandle: Int32,
        hashHandle: Int32,
        nameHandle: Int32,
        attributesHandle: Int32,
        creatorHandle: Int32,
        royaltiesHandle: Int32,
        urisHandle: Int32
    ) {
        return SpaceKit.managedGetESDTTokenData(
            addressHandle: addressHandle,
            tokenIDHandle: tokenIDHandle,
            nonce: nonce,
            valueHandle: valueHandle,
            propertiesHandle: propertiesHandle,
            hashHandle: hashHandle,
            nameHandle: nameHandle,
            attributesHandle: attributesHandle,
            creatorHandle: creatorHandle,
            royaltiesHandle: royaltiesHandle,
            urisHandle: urisHandle
        )
    }
}

// MARK: CallValueApiProtocol Implementation

extension VMApi: CallValueApiProtocol {
    mutating func bigIntGetCallValue(dest: Int32) {
        return SpaceKit.bigIntGetCallValue(dest: dest)
    }

    mutating func managedGetMultiESDTCallValue(resultHandle: Int32) {
        return SpaceKit.managedGetMultiESDTCallValue(resultHandle: resultHandle)
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
        return SpaceKit.managedMultiTransferESDTNFTExecute(
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
        return SpaceKit.managedTransferValueExecute(
            dstHandle: dstHandle,
            valueHandle: valueHandle,
            gasLimit: gasLimit,
            functionHandle: functionHandle,
            argumentsHandle: argumentsHandle
        )
    }
    
    mutating func managedExecuteOnDestContext(
        gas: Int64,
        addressHandle: Int32,
        valueHandle: Int32,
        functionHandle: Int32,
        argumentsHandle: Int32,
        resultHandle: Int32
    ) -> Int32 {
        return SpaceKit.managedExecuteOnDestContext(
            gas: gas,
            addressHandle: addressHandle,
            valueHandle: valueHandle,
            functionHandle: functionHandle,
            argumentsHandle: argumentsHandle,
            resultHandle: resultHandle
        )
    }
    
    mutating func managedCreateAsyncCall(
        dstHandle: Int32,
        valueHandle: Int32,
        functionHandle: Int32,
        argumentsHandle: Int32,
        successOffset: UnsafeRawPointer,
        successLength: Int32,
        errorOffset: UnsafeRawPointer,
        errorLength: Int32,
        gas: Int64,
        extraGasForCallback: Int64,
        callbackClosureHandle: Int32
    ) -> Int32 {
        return SpaceKit.managedCreateAsyncCall(
            dstHandle: dstHandle,
            valueHandle: valueHandle,
            functionHandle: functionHandle,
            argumentsHandle: argumentsHandle,
            successOffset: successOffset,
            successLength: successLength,
            errorOffset: errorOffset,
            errorLength: errorLength,
            gas: gas,
            extraGasForCallback: extraGasForCallback,
            callbackClosureHandle: callbackClosureHandle
        )
    }
    
    mutating func managedDeployFromSourceContract(
        gas: Int64,
        valueHandle: Int32,
        addressHandle: Int32,
        codeMetadataHandle: Int32,
        argumentsHandle: Int32,
        resultAddressHandle: Int32,
        resultHandle: Int32
    ) -> Int32 {
        return SpaceKit.managedDeployFromSourceContract(
            gas: gas,
            valueHandle: valueHandle,
            addressHandle: addressHandle,
            codeMetadataHandle: codeMetadataHandle,
            argumentsHandle: argumentsHandle,
            resultAddressHandle: resultAddressHandle,
            resultHandle: resultHandle
        )
    }
    
    mutating func managedUpgradeFromSourceContract(
        dstHandle: Int32,
        gas: Int64,
        valueHandle: Int32,
        addressHandle: Int32,
        codeMetadataHandle: Int32,
        argumentsHandle: Int32,
        resultHandle: Int32
    ) {
        return SpaceKit.managedUpgradeFromSourceContract(
            dstHandle: dstHandle,
            gas: gas,
            valueHandle: valueHandle,
            addressHandle: addressHandle,
            codeMetadataHandle: codeMetadataHandle,
            argumentsHandle: argumentsHandle,
            resultHandle: resultHandle
        )
    }
    
    mutating func cleanReturnData() {
        return SpaceKit.cleanReturnData()
    }
}

// MARK: ErrorApiProtocol implementation

extension VMApi: ErrorApiProtocol {
    mutating func managedSignalError(messageHandle: Int32) -> Never {
        SpaceKit.managedSignalError(messageHandle: messageHandle)
        fatalError()
    }
}

// MARK: LogApiProtocol implementation

extension VMApi: LogApiProtocol {
    mutating func managedWriteLog(topicsHandle: Int32, dataHandle: Int32) {
        SpaceKit.managedWriteLog(topicsHandle: topicsHandle, dataHandle: dataHandle)
    }
}

// MARK: CryptoApiProtocol implementation {
extension VMApi: CryptoApiProtocol {
    mutating func managedVerifyEd25519(keyHandle: Int32, messageHandle: Int32, sigHandle: Int32) -> Int32 {
        return SpaceKit.managedVerifyEd25519(keyHandle: keyHandle, messageHandle: messageHandle, sigHandle: sigHandle)
    }
    
    mutating func managedSha256(inputHandle: Int32, outputHandle: Int32) -> Int32 {
        return SpaceKit.managedSha256(inputHandle: inputHandle, outputHandle: outputHandle)
    }
}

#endif
