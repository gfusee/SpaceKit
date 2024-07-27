import MultiversX

@Codable public struct DepositInfo {
    let depositorAddress: Address
    let esdtFunds: MXArray<TokenPayment>
    let egldFunds: BigUint
    let valability: UInt64
    let expirationRound: UInt64
    var fees: Fee
}

@Codable public struct Fee {
    let numTokenToTransfer: UInt32
    var value: TokenPayment
}
