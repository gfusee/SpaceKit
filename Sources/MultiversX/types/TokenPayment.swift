let ESDT_LOCAL_BURN_FUNC_NAME: StaticString = "ESDTLocalBurn"
let ESDT_NFT_BURN_FUNC_NAME: StaticString = "ESDTNFTBurn"

// TODO: Use TokenIdentifier instead of MXBuffer for tokenIdentifier
@Codable public struct TokenPayment: Equatable {
    public var tokenIdentifier: MXBuffer
    public var nonce: UInt64
    public var amount: BigUint
}

extension TokenPayment {
    // TODO: remove the below function once the default init is made public in the @Codable macro
    public static func new(tokenIdentifier: MXBuffer, nonce: UInt64, amount: BigUint) -> TokenPayment {
        return TokenPayment(tokenIdentifier: tokenIdentifier, nonce: nonce, amount: amount)
    }
    
    public func burn() {
        // TODO: add tests
        var arguments = ArgBuffer()
        let endpoint: StaticString
        
        if self.nonce == 0 {
            arguments.pushArg(arg: self.tokenIdentifier)
            arguments.pushArg(arg: self.amount)
            
            endpoint = ESDT_LOCAL_BURN_FUNC_NAME
        } else {
            arguments.pushArg(arg: self.tokenIdentifier)
            arguments.pushArg(arg: self.nonce)
            arguments.pushArg(arg: self.amount)
            
            endpoint = ESDT_LOCAL_BURN_FUNC_NAME
        }
        
        
        let _: IgnoreValue = ContractCall(
            receiver: Blockchain.getSCAddress(),
            endpointName: MXBuffer(stringLiteral: endpoint),
            argBuffer: arguments
        ).call()
    }
}
