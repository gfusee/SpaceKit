package typealias Bytes8 = (
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8
)

package func getZeroedBytes8() -> Bytes8 {
    return (
        0, 0, 0, 0,
        0, 0, 0, 0
    )
}

package func toBigEndianUInt64(from tuple: Bytes8) -> UInt64 {
    var result: UInt64 = 0
    
    withUnsafeMutableBytes(of: &result) { resultMutablePointer in
        withUnsafeBytes(of: tuple) { tuplePointer in
            resultMutablePointer.copyMemory(from: tuplePointer)
        }
    }
    
    return result.bigEndian
}

package func toBigEndianInt64(from tuple: Bytes8) -> Int64 {
    var result: Int64 = 0
    
    withUnsafeMutableBytes(of: &result) { resultMutablePointer in
        withUnsafeBytes(of: tuple) { tuplePointer in
            resultMutablePointer.copyMemory(from: tuplePointer)
        }
    }
    
    return result.bigEndian
}

package func accessNthElementOfBytes8(index: Int32, bytes: Bytes8) -> UInt8 {
    return switch index {
    case 0:
        bytes.0
    case 1:
        bytes.1
    case 2:
        bytes.2
    case 3:
        bytes.3
    case 4:
        bytes.4
    case 5:
        bytes.5
    case 6:
        bytes.6
    case 7:
        bytes.7
    default:
        fatalError()
    }
}

package func setNthElementOfBytes8(index: Int32, bytes: inout Bytes8, value: UInt8) {
    switch index {
    case 0:
        bytes.0 = value
    case 1:
        bytes.1 = value
    case 2:
        bytes.2 = value
    case 3:
        bytes.3 = value
    case 4:
        bytes.4 = value
    case 5:
        bytes.5 = value
    case 6:
        bytes.6 = value
    case 7:
        bytes.7 = value
    default:
        fatalError()
    }
}

package func toBytes4BigEndian(bytes8: Bytes8) -> Bytes4 {
    let isBytes4 = bytes8.0 + bytes8.1 + bytes8.2 + bytes8.3 == 0
    
    guard isBytes4 else {
        fatalError()
    }
    
    var bytes4 = getZeroedBytes4()
    bytes4.0 = bytes8.4
    bytes4.1 = bytes8.5
    bytes4.2 = bytes8.6
    bytes4.3 = bytes8.7
    
    return bytes4
}

package func toBytes2BigEndian(bytes8: Bytes8) -> Bytes2 {
    let isBytes2 = bytes8.0 + bytes8.1 + bytes8.2 + bytes8.3 + bytes8.4 + bytes8.5 == 0
    
    guard isBytes2 else {
        fatalError()
    }
    
    var bytes2 = getZeroedBytes2()
    bytes2.0 = bytes8.6
    bytes2.1 = bytes8.7
    
    return bytes2
}

extension Int32 {
    package func toBytes8() -> Bytes8 {
        // TODO: add tests
        
        let bytes4 = self.toBytes4()
        
        var result = getZeroedBytes8()
        
        result.4 = bytes4.0
        result.5 = bytes4.1
        result.6 = bytes4.2
        result.7 = bytes4.3
        
        return result
    }
}

extension Int64 {
    package func toBytes8() -> Bytes8 {
        // TODO: add tests
        var result = getZeroedBytes8()
        
        withUnsafeMutableBytes(of: &result) { resultMutablePointer in
            withUnsafeBytes(of: self.bigEndian) { selfPointer in
                resultMutablePointer.copyMemory(from: selfPointer)
            }
        }
        
        return result
    }
}

extension UInt64 {
    package func toBytes8() -> Bytes8 {
        // TODO: add tests
        var result = getZeroedBytes8()
        
        withUnsafeMutableBytes(of: &result) { resultMutablePointer in
            withUnsafeBytes(of: self.bigEndian) { selfPointer in
                resultMutablePointer.copyMemory(from: selfPointer)
            }
        }
        
        return result
    }
}

extension UInt32 {
    package func toBytes8() -> Bytes8 {
        // TODO: add tests
        
        let bytes4 = self.toBytes4()
        
        var result = getZeroedBytes8()
        
        result.4 = bytes4.0
        result.5 = bytes4.1
        result.6 = bytes4.2
        result.7 = bytes4.3
        
        return result
    }
}

extension UInt16 {
    package func toBytes8() -> Bytes8 {
        // TODO: add tests
        
        let bytes2 = self.toBytes2()
        
        var result = getZeroedBytes8()
        
        result.6 = bytes2.0
        result.7 = bytes2.1
        
        return result
    }
}

extension UInt8 {
    package func toBytes8() -> Bytes8 {
        // TODO: add tests
        
        var result = getZeroedBytes8()
        
        result.7 = self
        
        return result
    }
}
