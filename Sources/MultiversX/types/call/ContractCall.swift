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
        
        return ReturnType(topDecodeMulti: &resultBuffers)
    }
}
