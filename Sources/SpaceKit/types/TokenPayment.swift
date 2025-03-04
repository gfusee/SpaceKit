@Codable public struct TokenPayment: Equatable {
    public var tokenIdentifier: TokenIdentifier
    public var nonce: UInt64
    public var amount: BigUint
}
