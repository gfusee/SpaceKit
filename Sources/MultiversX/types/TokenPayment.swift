// TODO: Use TokenIdentifier instead of MXBuffer for tokenIdentifier
@Codable public struct TokenPayment {
    public let tokenIdentifier: MXBuffer
    public let nonce: UInt64
    public let amount: BigUint
}

extension TokenPayment {
    public static func new(tokenIdentifier: MXBuffer, nonce: UInt64, amount: BigUint) -> TokenPayment {
        return TokenPayment(tokenIdentifier: tokenIdentifier, nonce: nonce, amount: amount)
    }
}
