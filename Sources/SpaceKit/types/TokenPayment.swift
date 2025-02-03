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
}
