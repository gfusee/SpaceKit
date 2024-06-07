#if !WASM
import Foundation
import BigInt

public struct DummyApi {
    package var lock: NSLock = NSLock()
    package var containers: [TransactionContainer] = [TransactionContainer()] // TODO: only two container are necessary: root (static use) and one transaction
    package var worldState = WorldState()
    
    package mutating func pushNewContainer(contractAddress: String) {
        self.containers.append(
            TransactionContainer(
                worldState: self.worldState,
                currentContractAddress: contractAddress
            )
        )
    }
    
    package mutating func popContainer() {
        if let container = self.containers.popLast(),
           container.error == nil {
            // TODO: add tests that ensure an execution error "reverts" the state
            // Commit the container into the state
            self.worldState = container.state
        }
    }
    
    package func getCurrentContainer() -> TransactionContainer {
        guard let container = self.containers.last else {
            fatalError("No current container.")
        }
        
        return container
    }
    
    package func getAccount(addressData: Data) -> WorldAccount? {
        return self.worldState.getAccount(addressData: addressData)
    }
    
    package mutating func setWorld(world: WorldState) {
        self.worldState = world
    }
    
    mutating func throwUserError(message: String) -> Never {
        withUnsafeCurrentTask(body: { task in
            if let task = task, !task.isCancelled {
                self.getCurrentContainer().error = .userError(message: message)
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
        self.getCurrentContainer().managedBuffersData[handle] = data
        
        return 0
    }
    
    public mutating func bufferCopyByteSlice(
        sourceHandle: Int32,
        startingPosition: Int32,
        sliceLength: Int32,
        destinationHandle: Int32
    ) -> Int32 {
        let sourceData = self.getCurrentContainer().getBufferData(handle: sourceHandle)
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
        
        self.getCurrentContainer().managedBuffersData[destinationHandle] = slice
        
        return 0
    }

    public mutating func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32 {
        let accumulatorData = self.getCurrentContainer().getBufferData(handle: accumulatorHandle)
        let data = self.getCurrentContainer().getBufferData(handle: dataHandle)
        
        self.getCurrentContainer().managedBuffersData[accumulatorHandle] = accumulatorData + data
        
        return 0
    }
    
    public func bufferGetLength(handle: Int32) -> Int32 {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return Int32(data.count)
    }
    
    public func bufferGetBytes(handle: Int32, resultPointer: UnsafeRawPointer) -> Int32 {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        let unsafeBufferPointer = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(mutating: resultPointer), count: data.count)
        
        data.copyBytes(to: unsafeBufferPointer)
        
        return 0
    }

    public mutating func bufferFinish(handle: Int32) -> Int32 {
        return 0
    }
    
    public mutating func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bigInt = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        
        self.getCurrentContainer().managedBuffersData[bufferHandle] = bigInt.toBigEndianUnsignedData()
        
        return 0
    }
    
    public mutating func bufferToBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bufferData = self.getCurrentContainer().getBufferData(handle: bufferHandle)
        let signData = "00".hexadecimal
        
        self.getCurrentContainer().managedBigIntData[bigIntHandle] = BigInt(signData + bufferData)
        
        return 0
    }
    
    public mutating func bufferEqual(handle1: Int32, handle2: Int32) -> Int32 {
        let data1 = self.getCurrentContainer().getBufferData(handle: handle1)
        let data2 = self.getCurrentContainer().getBufferData(handle: handle2)
        
        return data1 == data2 ? 1 : 0
    }
    
    public mutating func bufferToDebugString(handle: Int32) -> String {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return data.hexEncodedString()
    }
    
    public mutating func bufferToUTF8String(handle: Int32) -> String? {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return String(data: data, encoding: .utf8)
    }
}

extension DummyApi: BigIntApiProtocol {
    public mutating func bigIntSetInt64(destination: Int32, value: Int64) {
        self.getCurrentContainer().managedBigIntData[destination] = BigInt(integerLiteral: value)
    }
    
    public mutating func bigIntIsInt64(reference: Int32) -> Int32 {
        let value = self.getCurrentContainer().getBigIntData(handle: reference)
        
        return value <= BigInt(INT64_MAX) ? 1 : 0
    }
    
    public mutating func bigIntGetInt64Unsafe(reference: Int32) -> Int64 {
        let value = self.getCurrentContainer().getBigIntData(handle: reference)
        let formatted = value.formatted().replacingOccurrences(of: " ", with: "")
        
        return Int64(formatted)!
    }

    public mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        let bigIntValue = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        [UInt8](bigIntValue.formatted().utf8).withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress else {
                fatalError()
            }
            
            let _ = self.bufferSetBytes(handle: destHandle, bytePtr: baseAddress, byteLen: Int32(pointer.count))
        }
    }
    
    public mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        return lhs == rhs ? 0 : lhs > rhs ? 1 : -1
    }
    
    public mutating func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        let result = lhs + rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs > lhs {
            self.throwUserError(message: "Cannot substract because the result would be negative.")
            return
        }
        
        let result = lhs - rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        let result = lhs * rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.throwUserError(message: "Cannot divide by zero.")
            return
        }
        
        let result = lhs / rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.throwUserError(message: "Cannot divide by zero (modulo).")
            return
        }
        
        let result = lhs % rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public mutating func bigIntToString(bigIntHandle: Int32, destHandle: Int32) {
        let bigInt = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        let data = bigInt.description.data(using: .utf8)
        
        self.getCurrentContainer().managedBuffersData[destHandle] = data
    }
}

extension DummyApi: StorageApiProtocol {
    public mutating func bufferStorageLoad(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getCurrentContainer().getBufferData(handle: keyHandle)
        let currentStorage = self.getCurrentContainer().getStorageForCurrentContractAddress()
        
        let valueData = currentStorage[keyData] ?? Data()
        
        self.getCurrentContainer().managedBuffersData[bufferHandle] = valueData
        
        return 0
    }
    
    public mutating func bufferStorageStore(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getCurrentContainer().getBufferData(handle: keyHandle)
        let bufferData = self.getCurrentContainer().getBufferData(handle: bufferHandle)
        
        var currentStorage = self.getCurrentContainer().getStorageForCurrentContractAddress()
        currentStorage[keyData] = bufferData
        
        self.getCurrentContainer().setStorageForCurrentContractAddress(storage: currentStorage)
        
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
        let currentContractAddress = self.getCurrentContainer().getCurrentSCAccount()
        
        self.getCurrentContainer().managedBuffersData[resultHandle] = currentContractAddress.addressData
    }
}

extension DummyApi: SendApiProtocol {
    public mutating func managedTransferValueExecute(
        dstHandle: Int32,
        valueHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32 {
        // TODO: the current implementation doesn't care about sc-to-sc execution
        let sender = self.getCurrentContainer().getCurrentSCAccount()
        let value = self.getCurrentContainer().getBigIntData(handle: valueHandle)
        
        if value > sender.balance {
            // TODO: throw execution failed instead of user error
            // TODO: set the same error message than the SpaceVM
            self.throwUserError(message: "Not enough balance.")
        }
        
        let receiver = self.getCurrentContainer().getBufferData(handle: dstHandle)
        
        self.getCurrentContainer().addEgldToAddressBalance(address: sender.addressData, value: -value)
        self.getCurrentContainer().addEgldToAddressBalance(address: receiver, value: value)
        
        return 0
    }
}

extension DummyApi: ErrorApiProtocol {
    public mutating func managedSignalError(messageHandle: Int32) -> Never {
        let errorMessageData = self.getCurrentContainer().getBufferData(handle: messageHandle)
        self.throwUserError(message: String(data: errorMessageData, encoding: .utf8) ?? errorMessageData.hexEncodedString())
    }
}
#endif
