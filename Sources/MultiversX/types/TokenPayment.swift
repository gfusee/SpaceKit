// TODO: Use TokenIdentifier instead of MXBuffer for tokenIdentifier
@Codable public struct TokenPayment {
    let tokenIdentifier: MXBuffer
    let nonce: UInt64
    let amount: BigUint
}
