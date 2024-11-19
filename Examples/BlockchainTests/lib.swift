import Space

@Contract struct BlockchainTestsContract {
    public func getShard(address: Address) -> UInt32 {
        address.getShard()
    }
}
