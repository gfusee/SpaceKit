#if !WASM
import CryptoKit

package struct DeterministicRNG {
    private var state: UInt64

    init(
        txHash: Data,
        txCachePrevSeed: Data,
        txCacheCurrSeed: Data
    ) {
        
        let dataToHash = txHash + txCachePrevSeed + txCacheCurrSeed
        let hashedData = Data(SHA256.hash(data: dataToHash))
        
        self.state = hashedData.prefix(8).reduce(0) { (result, byte) in
            (result << 8) | UInt64(byte)
        }
    }

    mutating func nextByte() -> UInt8 {
        self.state = self.state &* 6364136223846793005 &+ 1
        return UInt8(self.state >> 56)
    }

    mutating func nextData(length: Int) -> Data {
        var randomData = Data()
        for _ in 0..<length {
            randomData.append(self.nextByte())
        }
        return randomData
    }
}
#endif
