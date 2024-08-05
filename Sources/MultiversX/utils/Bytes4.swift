package typealias Bytes4 = (
    UInt8, UInt8, UInt8, UInt8
)

package func getZeroedBytes4() -> Bytes4 {
    return (
        0, 0, 0, 0
    )
}

package func toBigEndianInt32(skipZerosCount: Int32, from tuple: Bytes4) -> Int32 {
    guard skipZerosCount < 4 else {
        if skipZerosCount == 4 {
            return 0
        } else {
            fatalError()
        }
    }
    
    var result: Int32 = 0
    
    let isNegative: Bool = accessNthElementOfBytes4(index: skipZerosCount, bytes: tuple) & 0x80 != 0
    
    let usefulBytesCount = 4 - skipZerosCount
    var counter: Int32 = 0
    while counter < 4 {
        let index = 3 - counter // from last to first
        let byteToShift: Int32
        if counter < usefulBytesCount {
            byteToShift = Int32(accessNthElementOfBytes4(index: index, bytes: tuple))
        } else {
            byteToShift = isNegative ? 0xFF : 0
        }
        
        result |= byteToShift << (counter * 8)
        
        counter += 1
    }
    
    return result
}

package func toBigEndianUInt32(from tuple: Bytes4) -> UInt32 {
    var result: UInt32 = 0
    
    // Shift and combine each byte into the result
    result |= UInt32(tuple.0) << 24
    result |= UInt32(tuple.1) << 16
    result |= UInt32(tuple.2) << 8
    result |= UInt32(tuple.3)
    
    return result
}

package func accessNthElementOfBytes4(index: Int32, bytes: Bytes4) -> UInt8 {
    return switch index {
    case 0:
        bytes.0
    case 1:
        bytes.1
    case 2:
        bytes.2
    case 3:
        bytes.3
    default:
        fatalError()
    }
}

extension Int32 {
    package func toBytes4() -> Bytes4 {
        // TODO: add tests
        var result = getZeroedBytes4()
        
        withUnsafeMutableBytes(of: &result) { resultMutablePointer in
            withUnsafeBytes(of: self.bigEndian) { selfPointer in
                resultMutablePointer.copyMemory(from: selfPointer)
            }
        }
        
        return result
    }
}

extension UInt32 {
    package func toBytes4() -> Bytes4 {
        // TODO: add tests
        var result = getZeroedBytes4()
        
        withUnsafeMutableBytes(of: &result) { resultMutablePointer in
            withUnsafeBytes(of: self.bigEndian) { selfPointer in
                resultMutablePointer.copyMemory(from: selfPointer)
            }
        }
        
        return result
    }
}
