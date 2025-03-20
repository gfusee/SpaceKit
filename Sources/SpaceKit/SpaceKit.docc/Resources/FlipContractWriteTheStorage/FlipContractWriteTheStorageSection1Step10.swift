import SpaceKit

@Codable public struct Flip {
    let id: UInt64
    let playerAddress: Address
    let tokenIdentifier: TokenIdentifier
    let tokenNonce: UInt64
    let amount: BigUint
    let bounty: BigUint
    let blockNonce: UInt64
}
