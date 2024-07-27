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
    
    public static var egldOrSingleEsdtTransfer: TokenPayment {
        let allEsdtTransfers = self.allEsdtTransfers
        let allEsdtTransfersCount = allEsdtTransfers.count
        
        if allEsdtTransfersCount == 0 {
            return TokenPayment.new(
                tokenIdentifier: "EGLD", // TODO: no hardcoded EGLD
                nonce: 0,
                amount: self.egldValue
            )
        } else {
            guard allEsdtTransfersCount == 1 else {
                smartContractError(message: "Too much payments received") // TODO: use the same error message as the WASM VM
            }
            
            return allEsdtTransfers.get(0)
        }
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
