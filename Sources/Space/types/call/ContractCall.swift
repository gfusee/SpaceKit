public struct ContractCall {
    let receiver: Address
    let endpointName: Buffer
    let argBuffer: ArgBuffer
    
    public init(
        receiver: Address,
        endpointName: Buffer,
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
        var resultBuffers = Vector<Buffer>()
        
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
    
    public func registerPromiseRaw(
        gas: UInt64,
        value: BigUint = 0,
        callbackName: StaticString? = nil,
        callbackArgs: ArgBuffer? = nil,
        gasForCallback: UInt64? = nil
    ) {
        let areCallbacksConsistent = (callbackName == nil && callbackArgs == nil && gasForCallback == nil) ||
                                     (callbackName != nil && callbackArgs != nil && gasForCallback != nil)
            
        guard areCallbacksConsistent else {
            smartContractError(message: "callbackName, callbackArgs, and gasForCallback must either all be nil or all non-nil.")
        }
        
        let callbackName = callbackName ?? ""
        
        let callbackNameLength = Int32(callbackName.utf8CodeUnitCount)
        let callbackNameStart = callbackName.utf8Start
        
        var callbackClosureSerialized = Buffer()
        if let callbackArgs = callbackArgs {
            callbackArgs.buffers.forEach { buffer in
                buffer.depEncode(dest: &callbackClosureSerialized)
            }
        }
        
        let gasForCallback: Int64 = if let gasForCallback = gasForCallback {
            Int64(gasForCallback) // TODO: Is this cast safe?
        } else {
            0
        }
        
        let _ = API.managedCreateAsyncCall(
            dstHandle: self.receiver.buffer.handle,
            valueHandle: value.handle,
            functionHandle: self.endpointName.handle,
            argumentsHandle: self.argBuffer.buffers.buffer.handle,
            successOffset: callbackNameStart,
            successLength: callbackNameLength,
            errorOffset: callbackNameStart,
            errorLength: callbackNameLength,
            gas: Int64(gas), // TODO: Is this cast safe?
            extraGasForCallback: gasForCallback,
            callbackClosureHandle: callbackClosureSerialized.handle
        )
    }
    
    public func registerPromise(
        gas: UInt64,
        value: BigUint = 0,
        callback: CallbackParams? = nil
    ) {
        // TODO: add tests
        self.registerPromiseRaw(
            gas: gas,
            value: value,
            callbackName: callback?.name,
            callbackArgs: callback?.args,
            gasForCallback: callback?.gas
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
    
    public func registerPromiseRaw(
        gas: UInt64,
        value: BigUint = 0,
        callbackName: StaticString? = nil,
        callbackArgs: ArgBuffer? = nil,
        gasForCallback: UInt64? = nil
    ) {
        self.contractCall
            .registerPromiseRaw(
                gas: gas,
                value: value,
                callbackName: callbackName,
                callbackArgs: callbackArgs,
                gasForCallback: gasForCallback
            )
    }
    
    public func registerPromise(
        gas: UInt64,
        value: BigUint = 0,
        callback: CallbackParams? = nil
    ) {
        self.contractCall
            .registerPromiseRaw(
                gas: gas,
                value: value,
                callbackName: callback?.name,
                callbackArgs: callback?.args,
                gasForCallback: callback?.gas
            )
    }
}
