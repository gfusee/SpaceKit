import SpaceKit

@Codable public struct PriceTag {
    let token: Buffer
    let nonce: UInt64
    let amount: BigUint
}
