#if !WASM
import Foundation
import BigInt

public struct DummyApi {
    private var managedBuffersData: [Int32 : Data] = [:]
    private var managedBigIntData: [Int32 : BigInt] = [:]
    public private(set) var errorMessage: String? = nil
    
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
    public mutating func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32 {
        let data = Data(bytes: bytePtr, count: Int(byteLen))
        self.managedBuffersData[handle] = data
        
        return 0
    }

    public mutating func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32 {
        let accumulatorData = self.getBufferData(handle: accumulatorHandle)
        let data = self.getBufferData(handle: dataHandle)
        
        self.managedBuffersData[accumulatorHandle] = accumulatorData + data 
        
        return 0
    }
    
    public func bufferGetLength(handle: Int32) -> Int32 {
        let data = self.getBufferData(handle: handle)
        
        return Int32(data.count)
    }
    
    public func bufferGetBytes(handle: Int32, resultPointer: UnsafeRawPointer) -> Int32 {
        return 0
    }

    public mutating func bufferFinish(handle: Int32) -> Int32 {
        return 0
    }
    
    public mutating func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        return 0
    }
    
    public mutating func bufferEqual(handle1: Int32, handle2: Int32) -> Int32 {
        let data1 = self.getBufferData(handle: handle1)
        let data2 = self.getBufferData(handle: handle2)
        
        return data1 == data2 ? 1 : 0
    }
}

extension DummyApi: BigIntApiProtocol {
    public mutating func bigIntSetInt64Value(destination: Int32, value: Int64) {
        self.managedBigIntData[destination] = BigInt(integerLiteral: value)
    }

    public mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        let bigIntValue = self.getBigIntData(handle: bigIntHandle)
        [UInt8](bigIntValue.formatted().utf8).withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress else {
                fatalError()
            }
            
            let _ = self.bufferSetBytes(handle: destHandle, bytePtr: baseAddress, byteLen: Int32(pointer.count))
        }
    }
    
    public mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        return lhs == rhs ? 0 : lhs > rhs ? 1 : -1
    }
    
    public mutating func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        let result = lhs + rhs
        
        self.managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        if rhs > lhs {
            self.errorMessage = "Cannot substract because the result would be negative."
            return
        }
        
        let result = lhs - rhs
        
        self.managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        let result = lhs * rhs
        
        self.managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.errorMessage = "Cannot divide by zero."
            return
        }
        
        let result = lhs / rhs
        
        self.managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.errorMessage = "Cannot divide by zero (modulo)."
            return
        }
        
        let result = lhs % rhs
        
        self.managedBigIntData[destHandle] = result
    }
}
#endif
