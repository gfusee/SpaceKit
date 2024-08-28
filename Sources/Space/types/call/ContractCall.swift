public struct ContractCall {
    let receiver: Address
    let endpointName: MXBuffer
    let argBuffer: ArgBuffer
    
    public init(
        receiver: Address,
        endpointName: MXBuffer,
        argBuffer: ArgBuffer
    ) {
        self.receiver = receiver
        self.endpointName = endpointName
        self.argBuffer = argBuffer
    }
    
    public func transferExecute(
        gas: UInt64 = Blockchain.getGasLeft(),
        value: BigUint = 0
    ) {
        let _ = API.managedTransferValueExecute(
            dstHandle: self.receiver.buffer.handle,
            valueHandle: value.handle,
            gasLimit: Int64(gas),
            functionHandle: self.endpointName.handle,
            argumentsHandle: self.argBuffer.buffers.buffer.handle
        )
    }
    
    public func call<ReturnType: TopDecodeMulti>(
        gas: UInt64 = Blockchain.getGasLeft(),
        value: BigUint = 0
    ) -> ReturnType {
        var resultBuffers = MXArray<MXBuffer>()
        
        let _ = API.managedExecuteOnDestContext(
            gas: Int64(gas), // TODO: Is this cast safe?
            addressHandle: self.receiver.buffer.handle,
            valueHandle: value.handle,
            functionHandle: self.endpointName.handle,
            argumentsHandle: self.argBuffer.buffers.buffer.handle,
            resultHandle: resultBuffers.buffer.handle
        )
        
        API.cleanReturnData()
        
        return ReturnType(topDecodeMulti: &resultBuffers)
    }
    
    public func registerPromise(
        callbackName: StaticString,
        gas: UInt64,
        gasForCallback: UInt64,
        callbackArgs: ArgBuffer,
        value: BigUint = 0
    ) {
        let callbackNameLength = Int32(callbackName.utf8CodeUnitCount)
        let callbackName = callbackName.utf8Start
        
        var callbackClosureSerialized = MXBuffer()
        callbackArgs.buffers.forEach { buffer in
            buffer.depEncode(dest: &callbackClosureSerialized)
        }
        
        let _ = API.managedCreateAsyncCall(
            dstHandle: self.receiver.buffer.handle,
            valueHandle: value.handle,
            functionHandle: self.endpointName.handle,
            argumentsHandle: self.argBuffer.buffers.buffer.handle,
            successOffset: callbackName,
            successLength: callbackNameLength,
            errorOffset: callbackName,
            errorLength: callbackNameLength,
            gas: Int64(gas), // TODO: Is this cast safe?
            extraGasForCallback: Int64(gasForCallback), // TODO: Is this cast safe?
            callbackClosureHandle: callbackClosureSerialized.handle
        )
    }
}

/// A wrapper around the ContractCall structure which marks the call as async only.
/// For example, token issuance calls should not be done synchronously.
public struct AsyncContractCall {
    private let contractCall: ContractCall
    
    package init(contractCall: ContractCall) {
        self.contractCall = contractCall
    }
    
    public func registerPromise(
        callbackName: StaticString,
        gas: UInt64,
        gasForCallback: UInt64,
        callbackArgs: ArgBuffer,
        value: BigUint = 0
    ) {
        self.contractCall
            .registerPromise(
                callbackName: callbackName,
                gas: gas,
                gasForCallback: gasForCallback,
                callbackArgs: callbackArgs
            )
    }
}
