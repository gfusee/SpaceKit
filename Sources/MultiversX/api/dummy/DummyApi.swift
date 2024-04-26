#if !WASM
import Foundation
import BigInt

struct DummyApi {
    private var managedBuffersData: [Int32 : Data] = [:]
    private var managedBigIntData: [Int32 : BigInt] = [:]
    
    func getBufferData(handle: Int32) -> Data {
        guard let data = self.managedBuffersData[handle] else {
            fatalError("Buffer handle not found")
        }
        
        return data
    }
    
    func getBigIntData(handle: Int32) -> BigInt {
        guard let data = self.managedBigIntData[handle] else {
            fatalError("Big integer handle not found")
        }
        
        return data
    }
}

extension DummyApi: BufferApiProtocol {
    mutating func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32 {
        let data = Data(bytes: bytePtr, count: Int(byteLen))
        self.managedBuffersData[handle] = data
        
        return 0
    }

    mutating func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32 {
        let accumulatorData = self.getBufferData(handle: accumulatorHandle)
        let data = self.getBufferData(handle: dataHandle)
        
        self.managedBuffersData[accumulatorHandle] = accumulatorData + data 
        
        return 0
    }
    
    func bufferGetLength(handle: Int32) -> Int32 {
        let data = self.getBufferData(handle: handle)
        
        return Int32(data.count)
    }
    
    func bufferGetBytes(handle: Int32, resultPointer: UnsafeRawPointer) -> Int32 {
        return 0
    }

    mutating func bufferFinish(handle: Int32) -> Int32 {
        return 0
    }
    
    mutating func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        return 0
    }
    
    mutating func bufferEqual(handle1: Int32, handle2: Int32) -> Int32 {
        let data1 = self.getBufferData(handle: handle1)
        let data2 = self.getBufferData(handle: handle2)
        
        return data1 == data2 ? 1 : 0
    }
}

extension DummyApi: BigIntApiProtocol {
    mutating func bigIntSetInt64Value(destination: Int32, value: Int64) {
        self.managedBigIntData[destination] = BigInt(integerLiteral: value)
    }

    mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        let bigIntValue = self.getBigIntData(handle: bigIntHandle)
        [UInt8](bigIntValue.formatted().utf8).withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress else {
                fatalError()
            }
            
            let _ = self.bufferSetBytes(handle: destHandle, bytePtr: baseAddress, byteLen: Int32(pointer.count))
        }
    }
    
    mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        return lhs == rhs ? 0 : lhs > rhs ? 1 : -1
    }
}
#endif
