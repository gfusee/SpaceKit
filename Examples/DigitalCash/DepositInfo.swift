import SpaceKit

@Codable public struct DepositInfo {
    var depositorAddress: Address
    var esdtFunds: Vector<TokenPayment>
    var egldFunds: BigUint
    var valability: UInt64
    var expirationRound: UInt64
    var fees: Fee
}

@Codable public struct Fee {
    var numTokenToTransfer: UInt32
    var value: TokenPayment
}
