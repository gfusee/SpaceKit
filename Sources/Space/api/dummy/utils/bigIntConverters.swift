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
    
    init(bigUintData: Data) {
        let buffer = Buffer(data: Array((bigUintData)))
        let biguint = BigUint(topDecode: buffer)
        
        self.init(bigUint: biguint)
    }

    func toBigEndianUnsignedData() -> Data {
        let bigIntData = self.serialize()
        
        return bigIntData.count > 0 ? bigIntData[1...] : Data()
    }
}

extension BigUint {
    init(bigInt: BigInt) {
        self = BigUint(bigEndianBuffer: Buffer(data: Array(bigInt.toBigEndianUnsignedData())))
    }
}
#endif
