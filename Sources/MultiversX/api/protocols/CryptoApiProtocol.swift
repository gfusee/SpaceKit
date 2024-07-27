public protocol CryptoApiProtocol {
    mutating func managedVerifyEd25519(keyHandle: Int32, messageHandle: Int32, sigHandle: Int32) -> Int32
}
