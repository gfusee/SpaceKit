import SpaceKit

@Codable public struct PriceTag {
    let token: TokenIdentifier
    let nonce: UInt64
    let amount: BigUint
}
