public struct Message {
    private init() {}
    
    public static var egldValue: BigUint {
        // TODO: add caching
        let valueHandle = getNextHandle()
        
        API.bigIntGetCallValue(dest: valueHandle)
        
        return BigUint(handle: valueHandle)
    }

    public static var allEsdtTransfers: MXArray<TokenPayment> {
        // TODO: add caching
        let resultHandle = getNextHandle()
        
        API.managedGetMultiESDTCallValue(resultHandle: resultHandle)
        
        return MXArray(handle: resultHandle)
    }
    
    public static var caller: Address {
        // TODO: add caching
        // 32-bytes array allocated on the stack
        let callerBytes: [UInt8] = [
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0
        ]
        
        let _ = callerBytes.withUnsafeBytes { pointer in
            API.getCaller(resultOffset: pointer.baseAddress!)
        }
        
        return Address(buffer: MXBuffer(data: callerBytes))
    }
}
