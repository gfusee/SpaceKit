@Codable public struct TokenData {
    let tokenType: TokenType
    let amount: BigUint
    let frozen: Bool
    let hash: Buffer
    let name: Buffer
    let attributes: Buffer
    let creator: Address
    let royaties: BigUint
    let uris: Vector<Buffer>
}
