#if !WASM
import Foundation
import BigInt

public class DummyApi {
    private var containerLock: NSLock = NSLock()
    package var globalLock: NSLock = NSLock()
    
    package var staticContainer = TransactionContainer(errorBehavior: .fatalError)
    package var transactionContainer: TransactionContainer? = nil
    
    package var blockInfos = BlockInfos(
        timestamp: 0
    )
    
    package var worldState = WorldState()
    
    package func runTransactions(transactionInput: TransactionInput, transactionOutput: TransactionOutput? = nil, operations: @escaping () -> Void) throws(TransactionError) {
        self.containerLock.lock()
        
        while let transactionContainer = self.transactionContainer {
            if transactionContainer.error == nil {
                fatalError("A transaction is already ongoing. This error should never occur if you don't interact with the api directly.")
            }
        }
        
        // We have to keep it in a local variable to be sure to be able to access it in the defer clause
        let transactionContainer = TransactionContainer(
            worldState: self.worldState,
            transactionInput: transactionInput,
            errorBehavior: .blockThread
        )
        
        self.transactionContainer = transactionContainer

        defer {
            if let output = transactionContainer.transactionOutput {
                transactionOutput?.merge(output: output)
            }
            
            self.transactionContainer = nil
            self.containerLock.unlock()
        }
        
        var hasThreadStartedExecution = false
        
        let thread = Thread {
            hasThreadStartedExecution = true
            
            transactionContainer.performEgldOrEsdtTransfers(
                senderAddress: transactionInput.callerAddress,
                receiverAddress: transactionInput.contractAddress,
                egldValue: transactionInput.egldValue,
                esdtValue: transactionInput.esdtValue
            )
            
            operations()
        }
        
        thread.start()
        
        while !hasThreadStartedExecution || thread.isExecuting {
            if let transactionContainer = self.transactionContainer {
                if transactionContainer.error != nil {
                    transactionContainer.shouldExitThread = true
                    break
                }
            }
        }
        
        if let transactionError = transactionContainer.error {
            throw transactionError
        } else {
            // Commit the container into the state
            self.worldState = transactionContainer.state
            self.transactionContainer = nil
        }
    }
    
    package func registerContractEndpointSelectorForContractAddress(
        contractAddress: Data,
        selector: any ContractEndpointSelector
    ) {
        self.getCurrentContainer().registerContractEndpointSelectorForContractAccount(
            contractAddress: contractAddress,
            selector: selector
        )
    }
    
    // TODO: If we are in a transaction context and another thread wants to perform operations on the static, it will modify instead the transaction container.
    
    package func getCurrentContainer() -> TransactionContainer {
        var container = self.transactionContainer ?? self.staticContainer
        
        while let nestedCallContainer = container.nestedCallTransactionContainer {
            container = nestedCallContainer
        }
        
        return container
    }
    
    package func getAccount(addressData: Data) -> WorldAccount? {
        return self.worldState.getAccount(addressData: addressData)
    }
    
    package func setWorld(world: WorldState) {
        self.worldState = world
    }

    package func setCurrentSCOwnerAddress(owner: Data) {
        self.getCurrentContainer().setCurrentSCOwnerAddress(owner: owner)
    }
    
    public func throwFunctionNotFoundError() -> Never {
        self.getCurrentContainer().throwError(error: .executionFailed(reason: "invalid function (not found)")) // TODO: use the same error as in the WASM VM
    }
    
    func throwUserError(message: String) -> Never {
        self.getCurrentContainer().throwError(error: .userError(message: message))
    }
    
    func throwExecutionFailed(reason: String) -> Never {
        self.getCurrentContainer().throwError(error: .executionFailed(reason: reason))
    }
}

extension DummyApi: BufferApiProtocol {
    public func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32 {
        let data = Data(bytes: bytePtr, count: Int(byteLen))
        self.getCurrentContainer().managedBuffersData[handle] = data
        
        return 0
    }
    
    public func mBufferSetByteSlice(
        mBufferHandle: Int32,
        startingPosition: Int32,
        dataLength: Int32,
        dataOffset: UnsafeRawPointer
    ) -> Int32 {
        var bufferData = self.getCurrentContainer().getBufferData(handle: mBufferHandle)
        let bufferDataCountBefore = bufferData.count
        
        let sliceData = Data(bytes: dataOffset, count: Int(dataLength))
        
        bufferData[Int(startingPosition)..<Int(startingPosition + dataLength)] = sliceData
        
        let bufferDataCountAfter = bufferData.count
        
        guard bufferDataCountBefore == bufferDataCountAfter else {
            self.throwExecutionFailed(reason: "Data's size after slice replacement is different than before it.")
        }
        
        self.getCurrentContainer().managedBuffersData[mBufferHandle] = bufferData
        
        return 0
    }
    
    public func mBufferAppendBytes(accumulatorHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32 {
        fatalError()
    }
    
    public func bufferCopyByteSlice(
        sourceHandle: Int32,
        startingPosition: Int32,
        sliceLength: Int32,
        destinationHandle: Int32
    ) -> Int32 {
        let sourceData = self.getCurrentContainer().getBufferData(handle: sourceHandle)
        let endIndex = startingPosition + sliceLength
        
        guard sliceLength >= 0 else {
            throwUserError(message: "Negative slice length.")
        }
        
        guard startingPosition >= 0 else {
            throwUserError(message: "Negative start position.")
        }
        
        guard endIndex <= sourceData.count else {
            throwUserError(message: "Index out of range.")
        }
        
        let slice = sourceData[startingPosition..<endIndex]
        
        self.getCurrentContainer().managedBuffersData[destinationHandle] = slice
        
        return 0
    }

    public func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32 {
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

    public func bufferFinish(handle: Int32) -> Int32 {
        let currentContainer = self.getCurrentContainer()
        
        let outputData = currentContainer.getBufferData(handle: handle)
        
        self.getCurrentContainer().outputs.append(outputData)
        
        return 0
    }
    
    public func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bigInt = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        
        self.getCurrentContainer().managedBuffersData[bufferHandle] = bigInt.toBigEndianUnsignedData()
        
        return 0
    }
    
    public func bufferToBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bufferData = self.getCurrentContainer().getBufferData(handle: bufferHandle)
        let signData = "00".hexadecimal
        
        self.getCurrentContainer().managedBigIntData[bigIntHandle] = BigInt(signData + bufferData)
        
        return 0
    }
    
    public func bufferEqual(handle1: Int32, handle2: Int32) -> Int32 {
        let data1 = self.getCurrentContainer().getBufferData(handle: handle1)
        let data2 = self.getCurrentContainer().getBufferData(handle: handle2)
        
        return data1 == data2 ? 1 : 0
    }
    
    public func mBufferSetRandom(destinationHandle: Int32, length: Int32) -> Int32 {
        fatalError() // TODO: implement and test
    }
    
    public func bufferToDebugString(handle: Int32) -> String {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return data.hexEncodedString()
    }
    
    public func bufferToUTF8String(handle: Int32) -> String? {
        let data = self.getCurrentContainer().getBufferData(handle: handle)
        
        return String(data: data, encoding: .utf8)
    }
    
    public func managedBufferToHex(sourceHandle: Int32, destinationHandle: Int32) {
        // TODO: add tests for this opcode
        let sourceData = self.getCurrentContainer().getBufferData(handle: sourceHandle)
        let destinationData = sourceData.hexEncodedString().data(using: .utf8)
        
        self.getCurrentContainer().managedBuffersData[destinationHandle] = destinationData
    }
}

extension DummyApi: BigIntApiProtocol {
    public func bigIntSetInt64(destination: Int32, value: Int64) {
        self.getCurrentContainer().managedBigIntData[destination] = BigInt(integerLiteral: value)
    }
    
    public func bigIntIsInt64(reference: Int32) -> Int32 {
        let value = self.getCurrentContainer().getBigIntData(handle: reference)
        
        return value <= BigInt(Int64.max) ? 1 : 0
    }
    
    public func bigIntGetInt64Unsafe(reference: Int32) -> Int64 {
        let value = self.getCurrentContainer().getBigIntData(handle: reference)
        let formatted = String(value).replacingOccurrences(of: " ", with: "")
        
        return Int64(formatted)!
    }

    public func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32) {
        let bigIntValue = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        var bigIntValueData: [UInt8] = Array(String(bigIntValue).data(using: .utf8)!)
        
        let _ = self.bufferSetBytes(handle: destHandle, bytePtr: &bigIntValueData, byteLen: Int32(bigIntValueData.count))
    }
    
    public func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32 {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        return lhs == rhs ? 0 : lhs > rhs ? 1 : -1
    }
    
    public func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        let result = lhs + rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs > lhs {
            self.throwUserError(message: "Cannot substract because the result would be negative.")
        }
        
        let result = lhs - rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        let result = lhs * rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntTDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.throwUserError(message: "Cannot divide by zero.")
        }
        
        let result = lhs / rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntTMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32) {
        let lhs = self.getCurrentContainer().getBigIntData(handle: lhsHandle)
        let rhs = self.getCurrentContainer().getBigIntData(handle: rhsHandle)
        
        if rhs == 0 {
            self.throwUserError(message: "Cannot divide by zero (modulo).")
        }
        
        let result = lhs % rhs
        
        self.getCurrentContainer().managedBigIntData[destHandle] = result
    }
    
    public func bigIntToString(bigIntHandle: Int32, destHandle: Int32) {
        let bigInt = self.getCurrentContainer().getBigIntData(handle: bigIntHandle)
        let data = bigInt.description.data(using: .utf8)
        
        self.getCurrentContainer().managedBuffersData[destHandle] = data
    }
}

extension DummyApi: StorageApiProtocol {
    public func bufferStorageLoad(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getCurrentContainer().getBufferData(handle: keyHandle)
        let currentStorage = self.getCurrentContainer().getStorageForCurrentContractAddress()
        
        let valueData = currentStorage[keyData] ?? Data()
        
        self.getCurrentContainer().managedBuffersData[bufferHandle] = valueData
        
        return 0
    }
    
    public func bufferStorageStore(keyHandle: Int32, bufferHandle: Int32) -> Int32 {
        let keyData = self.getCurrentContainer().getBufferData(handle: keyHandle)
        let bufferData = self.getCurrentContainer().getBufferData(handle: bufferHandle)
        
        var currentStorage = self.getCurrentContainer().getStorageForCurrentContractAddress()
        currentStorage[keyData] = bufferData
        
        self.getCurrentContainer().setStorageForCurrentContractAddress(storage: currentStorage)
        
        return 0
    }
}

extension DummyApi: EndpointApiProtocol {
    public func getNumArguments() -> Int32 {
        return Int32(self.getCurrentContainer().getEndpointInputArguments().count) // TODO: is it ok that this cast is unsafe?
    }
    
    func bufferGetArgument(argId: Int32, bufferHandle: Int32) -> Int32 {
        let currentContainer = self.getCurrentContainer()
        let arguments = currentContainer.getEndpointInputArguments()
        
        guard argId < arguments.count else {
            self.throwExecutionFailed(reason: "Argument out of range.") // TODO: use the same message as the WASM VM
        }
        
        let data = arguments[Int(argId)]
        
        currentContainer.managedBuffersData[bufferHandle] = data
        
        return 0
    }
}

extension DummyApi: BlockchainApiProtocol {
    public func managedSCAddress(resultHandle: Int32) {
        let currentContractAccount = self.getCurrentContainer().getCurrentSCAccount()
        
        self.getCurrentContainer().managedBuffersData[resultHandle] = currentContractAccount.addressData
    }
    
    public func getBlockTimestamp() -> Int64 {
        return self.blockInfos.timestamp
    }
    
    public func getBlockRound() -> Int64 {
        fatalError() // TODO: implement and test
    }
    
    public func bigIntGetExternalBalance(addressPtr: UnsafeRawPointer, dest: Int32) {
        let addressData = Data(bytes: addressPtr, count: 32)
        
        guard let account = self.getAccount(addressData: addressData)
        else {
            self.getCurrentContainer().managedBigIntData[dest] = 0
            
            return
        }
        
        self.getCurrentContainer().managedBigIntData[dest] = account.balance
    }
    
    public func bigIntGetESDTExternalBalance(addressPtr: UnsafeRawPointer, tokenIDOffset: UnsafeRawPointer, tokenIDLen: Int32, nonce: Int64, dest: Int32) {
        let addressData = Data(bytes: addressPtr, count: 32)
        let tokenIdData = Data(bytes: tokenIDOffset, count: Int(tokenIDLen))
        
        guard let account = self.getAccount(addressData: addressData),
              let tokenBalances = account.esdtBalances[tokenIdData],
              let balance = tokenBalances.first(where: { $0.nonce == nonce })
        else {
            self.getCurrentContainer().managedBigIntData[dest] = 0
            
            return
        }
        
        self.getCurrentContainer().managedBigIntData[dest] = balance.balance
    }
    
    public func getCaller(resultOffset: UnsafeRawPointer) {
        let callerAccount = self.getCurrentContainer().getCurrentCallerAccount()
        let callerAccountAddressData = callerAccount.addressData
        
        let mutablePointer = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(mutating: resultOffset), count: callerAccountAddressData.count)
        
        callerAccountAddressData.copyBytes(to: mutablePointer)
    }

    public func managedOwnerAddress(resultHandle: Int32) {
        let ownerAccount = self.getCurrentContainer().getCurrentSCOwnerAccount()

        self.getCurrentContainer().managedBuffersData[resultHandle] = ownerAccount.addressData 
    }
    
    public func getGasLeft() -> Int64 {
        return 100 // TODO: the RustVM implements this the same way, in the future we should provide a real implementation
    }
    
    public func getESDTLocalRoles(tokenIdHandle: Int32) -> Int64 {
        // TODO: implement and tests
        fatalError()
    }
}

extension DummyApi: CallValueApiProtocol {
    public func bigIntGetCallValue(dest: Int32) {
        let value = self.getCurrentContainer().getEgldValue()

        self.getCurrentContainer().managedBigIntData[dest] = value
    }

    public func managedGetMultiESDTCallValue(resultHandle: Int32) {
        let payments = self.getCurrentContainer().getEsdtValue()

        var array: MXArray<TokenPayment> = []
        for payment in payments {
            array = array.appended(
                TokenPayment.new(
                    tokenIdentifier: MXBuffer(data: Array(payment.tokenIdentifier)),
                    nonce: payment.nonce,
                    amount: BigUint(bigInt: payment.amount)
                )
            )
        }

        self.getCurrentContainer().managedBuffersData[resultHandle] = Data(array.buffer.toBytes())
    }
}

extension DummyApi: SendApiProtocol {
    public func managedMultiTransferESDTNFTExecute(
        dstHandle: Int32,
        tokenTransfersHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32 {
        // TODO: the current implementation doesn't care about sc-to-sc execution
        let sender = self.getCurrentContainer().getCurrentSCAccount()
        let receiver = self.getCurrentContainer().getBufferData(handle: dstHandle)
        
        var tokenTransfersBufferInput = BufferNestedDecodeInput(buffer: MXBuffer(handle: tokenTransfersHandle).clone())
        while tokenTransfersBufferInput.canDecodeMore() { // TODO: use managed vec once implemented
            let tokenPayment = TokenPayment(depDecode: &tokenTransfersBufferInput)
            let tokenIdentifier = self.getCurrentContainer().getBufferData(handle: tokenPayment.tokenIdentifier.handle)
            let value = self.getCurrentContainer().getBigIntData(handle: tokenPayment.amount.handle)
            
            if value > sender.balance {
                self.throwExecutionFailed(reason: "insufficient funds")
            }
            
            self.getCurrentContainer().performEsdtTransfer(from: sender.addressData, to: receiver, token: tokenIdentifier, nonce: tokenPayment.nonce, value: value)
        }
        
        return 0
    }
    
    public func managedTransferValueExecute(
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
            self.throwExecutionFailed(reason: "insufficient funds")
        }
        
        let receiver = self.getCurrentContainer().getBufferData(handle: dstHandle)

        self.getCurrentContainer().performEgldTransfer(from: sender.addressData, to: receiver, value: value)
        
        return 0
    }
    
    public func managedExecuteOnDestContext(
        gas: Int64,
        addressHandle: Int32,
        valueHandle: Int32,
        functionHandle: Int32,
        argumentsHandle: Int32,
        resultHandle: Int32
    ) -> Int32 {
        // TODO: test
        let currentTransactionContainer = self.getCurrentContainer()
        
        let sender = currentTransactionContainer.getCurrentSCAccount().addressData
        let receiver = currentTransactionContainer.getBufferData(handle: addressHandle)
        let value = currentTransactionContainer.getBigIntData(handle: valueHandle)
        let function = currentTransactionContainer.getBufferData(handle: functionHandle)
        
        let argumentsArray: MXArray<MXBuffer> = MXArray(handle: argumentsHandle)
        var arguments: [Data] = []
        
        argumentsArray.forEach { arguments.append(Data($0.toBytes())) }
        
        let results = currentTransactionContainer.performNestedContractCall(
            receiver: receiver,
            function: function,
            inputs: TransactionInput(
                contractAddress: receiver,
                callerAddress: sender,
                egldValue: value,
                esdtValue: [], // TODO: implement and test
                arguments: arguments
            )
        )
        
        var resultsArray: MXArray<MXBuffer> = MXArray()
        
        for result in results {
            resultsArray = resultsArray.appended(MXBuffer(data: Array(result)))
        }
        
        currentTransactionContainer.managedBuffersData[resultHandle] = Data(resultsArray.buffer.toBytes())
        
        return 0
    }
}

extension DummyApi: ErrorApiProtocol {
    public func managedSignalError(messageHandle: Int32) -> Never {
        let errorMessageData = self.getCurrentContainer().getBufferData(handle: messageHandle)
        self.throwUserError(message: String(data: errorMessageData, encoding: .utf8) ?? errorMessageData.hexEncodedString())
    }
}

extension DummyApi: LogApiProtocol {
    public func managedWriteLog(topicsHandle: Int32, dataHandle: Int32) {
        self.getCurrentContainer().writeLog(topicsHandle: topicsHandle, dataHandle: dataHandle)
    }
}

extension DummyApi: CryptoApiProtocol {
    public func managedVerifyEd25519(keyHandle: Int32, messageHandle: Int32, sigHandle: Int32) -> Int32 {
        fatalError() // TODO: implement and test
    }
}
#endif
