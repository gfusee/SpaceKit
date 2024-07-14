#if !WASM
import Foundation
import BigInt

extension BigInt {
    init(bigUint: BigUint) {
        var hexString = bigUint.toBytesBigEndianBuffer().hexDescription

        if hexString.isEmpty {
            hexString = "0"
        }

        self = BigInt(hexString, radix: 16)!
    }

    func toBigEndianUnsignedData() -> Data {
        let bigIntData = self.serialize()
        
        return bigIntData.count > 0 ? bigIntData[1...] : Data()
    }
}
#endif
