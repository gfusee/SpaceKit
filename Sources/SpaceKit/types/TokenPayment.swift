let ESDT_LOCAL_BURN_FUNC_NAME: StaticString = "ESDTBurn"
let ESDT_NFT_BURN_FUNC_NAME: StaticString = "ESDTNFTBurn"

// TODO: Use TokenIdentifier instead of Buffer for tokenIdentifier
@Codable public struct TokenPayment: Equatable {
    public var tokenIdentifier: Buffer
    public var nonce: UInt64
    public var amount: BigUint
}

extension TokenPayment {
    @available(*, deprecated, message: "This will be removed in a future version. Please use the public init.")
    public static func new(tokenIdentifier: Buffer, nonce: UInt64, amount: BigUint) -> TokenPayment {
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
            
            endpoint = ESDT_NFT_BURN_FUNC_NAME
        }
        
        
        let _: IgnoreValue = ContractCall(
            receiver: Blockchain.getSCAddress(),
            endpointName: Buffer(stringLiteral: endpoint),
            argBuffer: arguments
        ).call()
    }
}
