#if !WASM
import Foundation

extension String {
    public func toAddressData() -> Data {
        let data = self.hexadecimalString.hexadecimal
        
        let leadingZeros = Data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        
        let remainingLength = 32 - leadingZeros.count - data.count
        
        guard remainingLength >= 0 else {
            fatalError()
        }
        
        let underscoreHex = "_".hexadecimalString
        let underscoreHexByte = underscoreHex.hexadecimal
        var underscoreHexBytes = Data()
        
        while underscoreHexBytes.count < remainingLength {
            underscoreHexBytes += underscoreHexByte
        }
        
        let filledData = leadingZeros + data + underscoreHexBytes
        
        return filledData
    }
}
#endif
