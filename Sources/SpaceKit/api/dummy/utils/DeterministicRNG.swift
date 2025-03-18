package struct DeterministicRNG {
    private var state: UInt64

    init(
        txHash: Data,
        txCachePrevSeed: Data,
        txCacheCurrSeed: Data
    ) {
        var hasher = Hasher()
        
        hasher.combine(txCachePrevSeed)
        hasher.combine(txCacheCurrSeed)
        hasher.combine(txHash)
        
        self.state = UInt64(bitPattern: Int64(hasher.finalize()))
    }

    mutating func nextByte() -> UInt8 {
        self.state = self.state &* 6364136223846793005 &+ 1
        return UInt8(self.state >> 56)
    }

    mutating func nextData(length: Int) -> Data {
        var randomData = Data()
        for _ in 0..<length {
            randomData.append(nextByte())
        }
        return randomData
    }
}
