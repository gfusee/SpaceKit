#if !WASM
import Foundation
import BigInt

public struct DummyApi {
    package var lock: NSLock = NSLock()
    private var managedBuffersData: [Int32 : Data] = [:]
    private var managedBigIntData: [Int32 : BigInt] = [:]
    private var storageForContractAddress: [String : [Data : Data]] = [:]
    package var currentContractAddress: String? = nil
    public private(set) var errorMessage: String? = nil
    
    private func getBufferData(handle: Int32) -> Data {
        guard let data = self.managedBuffersData[handle] else {
            fatalError("Buffer handle not found")
        }
        
        return data
    }
    
    private func getBigIntData(handle: Int32) -> BigInt {
        guard let data = self.managedBigIntData[handle] else {
            fatalError("Big integer handle not found")
        }
        
        return data
    }
    
    package mutating func resetData() {
        self.managedBuffersData = [:]
        self.managedBigIntData = [:]
        self.storageForContractAddress = [:]
        self.currentContractAddress = nil
        self.errorMessage = nil
    }
    
    private func getCurrentContractAddress() -> String {
        guard let currentContractAddress = self.currentContractAddress else {
            fatalError("No current contract address. Are you in a transaction context?")
        }
        
        return currentContractAddress
    }
    
    private func getStorageForCurrentContractAddress() -> [Data : Data] {
        let currentContractAddress = self.getCurrentContractAddress()
        
        return self.storageForContractAddress[currentContractAddress] ?? [:]
    }
    
    private mutating func setStorageForCurrentContractAddress(storage: [Data : Data]) {
        let currentContractAddress = self.getCurrentContractAddress()
        
        self.storageForContractAddress[currentContractAddress] = storage
    }
    
    mutating func throwUserError(message: String) {
        withUnsafeCurrentTask(body: { task in
            if let task = task, !task.isCancelled {
                self.errorMessage = message
                task.cancel()
                while (true) {} // Wait for the task to be canceled, we don't want any instruction to be executed
            } else {
                fatalError(message)
            }
        })
    }
}

extension DummyApi: BufferApiProtocol {
    public mutating func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32 {
        let data = Data(bytes: bytePtr, count: Int(byteLen))
        self.managedBuffersData[handle] = data
        
        return 0
    }
    
    public mutating func bufferCopyByteSlice(
        sourceHandle: Int32,
        startingPosition: Int32,
        sliceLength: Int32,
        destinationHandle: Int32
    ) -> Int32 {
        let sourceData = self.getBufferData(handle: sourceHandle)
        let endIndex = startingPosition + sliceLength
        
        guard sliceLength >= 0 else {
            throwUserError(message: "Negative slice length.")
            return -1
        }
        
        guard startingPosition >= 0 else {
            throwUserError(message: "Negative start position.")
            return -1
        }
        
        guard endIndex <= sourceData.count else {
            throwUserError(message: "Index out of range.")
            return -1
        }
        
        let slice = sourceData[startingPosition..<endIndex]
        
        self.managedBuffersData[destinationHandle] = slice
        
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
        let data = self.getBufferData(handle: handle)
        let unsafeBufferPointer = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(mutating: resultPointer), count: data.count)
        
        data.copyBytes(to: unsafeBufferPointer)
        
        return 0
    }

    public mutating func bufferFinish(handle: Int32) -> Int32 {
        return 0
    }
    
    public mutating func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bigInt = self.getBigIntData(handle: bigIntHandle)
        let bigIntData = bigInt.serialize()
        let bigIntDataWithoutSign = bigIntData.count > 0 ? bigIntData[1...] : Data()
        
        self.managedBuffersData[bufferHandle] = bigIntDataWithoutSign
        
        return 0
    }
    
    public mutating func bufferToBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bufferData = self.getBufferData(handle: bufferHandle)
        let signData = "00".hexadecimal
        
        self.managedBigIntData[bigIntHandle] = BigInt(signData + bufferData)
        
        return 0
    }
    
    public mutating func bufferEqual(handle1: Int32, handle2: Int32) -> Int32 {
        let data1 = self.getBufferData(handle: handle1)
        let data2 = self.getBufferData(handle: handle2)
        
        return data1 == data2 ? 1 : 0
    }
    
    public mutating func bufferToDebugString(handle: Int32) -> String {
        let data = self.getBufferData(handle: handle)
        
        return data.hexEncodedString()
    }
    
    public mutating func bufferToUTF8String(handle: Int32) -> String? {
        let data = self.getBufferData(handle: handle)
        
        return String(data: data, encoding: .utf8)
    }
}

extension DummyApi: BigIntApiProtocol {
    public mutating func bigIntSetInt64(destination: Int32, value: Int64) {
        self.managedBigIntData[destination] = BigInt(integerLiteral: value)
    }
    
    public mutating func bigIntIsInt64(reference: Int32) -> Int32 {
        let value = self.getBigIntData(handle: reference)
        
        return value <= BigInt(INT64_MAX) ? 1 : 0
    }
    
    public mutating func bigIntGetInt64Unsafe(reference: Int32) -> Int64 {
        let value = self.getBigIntData(handle: reference)
        
        return Int64(value.formatted())!
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
            self.throwUserError(message: "Cannot substract because the result would be negative.")
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
            self.throwUserError(message: "Cannot divide by zero.")
            return
        }
        
        let result = lhs / rhs
        
        self.managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getBigIntData(handle: lhsHandle)
        let rhs = self.getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.throwUserError(message: "Cannot divide by zero (modulo).")
            return
        }
        
        let result = lhs % rhs
        
        self.managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntToString(bigIntHandle: Int32, destHandle: Int32) {
        let bigInt = self.getBigIntData(handle: bigIntHandle)
        let data = bigInt.description.data(using: .utf8)
        
        self.managedBuffersData[destHandle] = data
    }
}

extension DummyApi: StorageApiProtocol {
    public mutating func bufferStorageLoad(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getBufferData(handle: keyHandle)
        let currentStorage = self.getStorageForCurrentContractAddress()
        
        let valueData = currentStorage[keyData] ?? Data()
        
        self.managedBuffersData[bufferHandle] = valueData
        
        return 0
    }
    
    public mutating func bufferStorageStore(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getBufferData(handle: keyHandle)
        let bufferData = self.getBufferData(handle: bufferHandle)
        
        var currentStorage = self.getStorageForCurrentContractAddress()
        currentStorage[keyData] = bufferData
        
        self.setStorageForCurrentContractAddress(storage: currentStorage)
        
        return 0
    }
}

extension DummyApi: EndpointApiProtocol {
    public mutating func getNumArguments() -> Int32 {
        return 0
    }
    
    mutating func bufferGetArgument(argId: Int32, bufferHandle: Int32) -> Int32 {
        return 0
    }
}

extension DummyApi: BlockchainApiProtocol {
    public mutating func managedSCAddress(resultHandle: Int32) {
        let currentContractAddressHexString = self.getCurrentContractAddress().hexadecimalString
        let data = currentContractAddressHexString.hexadecimal
        
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
        
        self.managedBuffersData[resultHandle] = filledData
    }
}
#endif
