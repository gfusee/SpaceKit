// TODO: add tests

package typealias Bytes2 = (
    UInt8, UInt8
)

package func getZeroedBytes2() -> Bytes2 {
    return (
        0, 0
    )
}

package func toBigEndianInt16(skipZerosCount: Int32, from tuple: Bytes2) -> Int16 {
    guard skipZerosCount < 2 else {
        if skipZerosCount == 2 {
            return 0
        } else {
            fatalError()
        }
    }
    
    var result: Int16 = 0
    
    let isNegative: Bool = accessNthElementOfBytes2(index: skipZerosCount, bytes: tuple) & 0x80 != 0
    
    let usefulBytesCount = 4 - skipZerosCount
    var counter: Int32 = 0
    while counter < 4 {
        let index = 3 - counter // from last to first
        let byteToShift: Int16
        if counter < usefulBytesCount {
            byteToShift = Int16(accessNthElementOfBytes2(index: index, bytes: tuple))
        } else {
            byteToShift = isNegative ? 0xFF : 0
        }
        
        result |= byteToShift << (counter * 8)
        
        counter += 1
    }
    
    return result
}

package func toBigEndianUInt16(from tuple: Bytes2) -> UInt16 {
    var result: UInt16 = 0
    
    // Shift and combine each byte into the result
    result |= UInt16(tuple.0) << 8
    result |= UInt16(tuple.1)
    
    return result
}

package func accessNthElementOfBytes2(index: Int32, bytes: Bytes2) -> UInt8 {
    return switch index {
    case 0:
        bytes.0
    case 1:
        bytes.1
    default:
        fatalError()
    }
}

extension Int16 {
    package func toBytes2() -> Bytes2 {
        // TODO: add tests
        var result = getZeroedBytes2()
        
        withUnsafeMutableBytes(of: &result) { resultMutablePointer in
            withUnsafeBytes(of: self.bigEndian) { selfPointer in
                resultMutablePointer.copyMemory(from: selfPointer)
            }
        }
        
        return result
    }
}

extension UInt16 {
    package func toBytes2() -> Bytes2 {
        // TODO: add tests
        var result = getZeroedBytes2()
        
        withUnsafeMutableBytes(of: &result) { resultMutablePointer in
            withUnsafeBytes(of: self.bigEndian) { selfPointer in
                resultMutablePointer.copyMemory(from: selfPointer)
            }
        }
        
        return result
    }
}
