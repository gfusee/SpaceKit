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
        // TODO: add caching
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
    
    public static var singleEsdt: TokenPayment {
        // TODO: add caching
        
        let egldOrSingleEsdtTransfer = Message.egldOrSingleEsdtTransfer
        
        // TODO: no hardcoded EGLD
        guard egldOrSingleEsdtTransfer.tokenIdentifier != "EGLD" else {
            smartContractError(message: "incorrect number of ESDT transfers")
        }
        
        return egldOrSingleEsdtTransfer
    }
    
    public static var singleFungibleEsdt: TokenPayment {
        let singleEsdt = Message.singleEsdt
        
        guard singleEsdt.nonce == 0 else {
            smartContractError(message: "fungible ESDT token expected")
        }
        
        return singleEsdt
    }
    
    public static var caller: Address {
        // TODO: add caching
        // 32-bytes array allocated on the stack
        var callerBytes: Bytes32 = getZeroedBytes32()
        
        API.getCaller(resultOffset: &callerBytes)
        
        return Address(buffer: Buffer(data: callerBytes))
    }
    
    // TODO: maybe rename this func to getAsyncCallResult?
    public static func asyncCallResult<T>() -> AsyncCallResult<T> {
        // TODO: add caching
        // TODO: what's the behavior of this function being called in a non-callback execution?
        var endpointArgumentLoader = EndpointArgumentsLoader()
        
        return AsyncCallResult(topDecodeMulti: &endpointArgumentLoader)
    }
    
    public static var transactionHash: Buffer {
        // TODO: add caching
        var result = Buffer()
        
        API.managedGetOriginalTxHash(resultHandle: result.handle)
        
        return result
    }
}
