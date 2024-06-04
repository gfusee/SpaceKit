#if !WASM
import Foundation
import BigInt

extension BigInt {
    func toBigEndianUnsignedData() -> Data {
        let bigIntData = self.serialize()
        
        return bigIntData.count > 0 ? bigIntData[1...] : Data()
    }
}
#endif
