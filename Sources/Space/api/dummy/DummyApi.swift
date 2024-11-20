#if !WASM
import Foundation
import BigInt

public class DummyApi {
    private var numberOfShards: UInt8 = 3
    
    private var containerLock: NSLock = NSLock()
    package var globalLock: NSLock = NSLock()
    
    package var staticContainer = TransactionContainer(errorBehavior: .fatalError)
    package var transactionContainer: TransactionContainer? = nil
    
    package var blockInfos = BlockInfos(
        timestamp: 0
    )
    
    package var worldState = WorldState()
    
    package func runTransactions(
        transactionInput: TransactionInput,
        transactionOutput: TransactionOutput? = nil,
        executionType: TransactionContainerExecutionType = .sync,
        operations: UncheckedClosure
    ) throws(TransactionError) -> (results: [Data], asyncError: TransactionError?) {
        self.containerLock.lock()
        
        while let transactionContainer = self.transactionContainer {
            if transactionContainer.error == nil {
                fatalError("A transaction is already ongoing. This error should never occur if you don't interact with the api directly.")
            }
        }
        
        let transactionContainer = TransactionContainer(
            worldState: self.worldState,
            transactionInput: transactionInput,
            executionType: executionType,
            errorBehavior: .blockThread,
            byTransferringDataFrom: self.staticContainer
        )
        
        self.transactionContainer = transactionContainer
        
        nonisolated(unsafe) var hasThreadStartedExecution = false
        
        let thread = Thread {
            hasThreadStartedExecution = true
            
            transactionContainer.performEgldOrEsdtTransfers(
                senderAddress: transactionInput.callerAddress,
                receiverAddress: transactionInput.contractAddress,
                egldValue: transactionInput.egldValue,
                esdtValue: transactionInput.esdtValue
            )
            
            operations.closure()
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
        
        let containerExecutionType = transactionContainer.executionType
        let containerPendingAsyncExecutions = transactionContainer.pendingAsyncExecutions
        let containerOutputs = transactionContainer.outputs
        
        var error: (error: TransactionError, shouldThrow: Bool)?
        
        if let transactionError = transactionContainer.error {
            let shouldThrow = !self.shouldContinueExecutionAfterError(executionType: containerExecutionType, pendingAsyncExecutions: containerPendingAsyncExecutions)
            
            error = (error: transactionError, shouldThrow: shouldThrow)
        } else {
            // Commit the container into the state
            self.worldState = transactionContainer.state
        }
        
        if let output = transactionContainer.transactionOutput {
            transactionOutput?.merge(output: output)
        }
        
        self.transactionContainer = nil
        self.containerLock.unlock()
        
        if let error = error {
            if error.shouldThrow {
                throw error.error
            }
        }
        
        var pendingAsyncExecutions: [AsyncCallInput] = containerPendingAsyncExecutions
        
        while !pendingAsyncExecutions.isEmpty {
            let pendingAsyncExecution = pendingAsyncExecutions.removeFirst()
            
            let pendingCallbackExecution = self.executePendingAsyncExecution(execution: pendingAsyncExecution)
            
            if let pendingCallbackExecution = pendingCallbackExecution {
                pendingAsyncExecutions.append(pendingCallbackExecution)
            }
        }
        
        return (results: containerOutputs, asyncError: error?.error)
    }
    
    public func setNumberOfShards(shards: UInt8) {
        self.numberOfShards = shards
    }
    
    public func registerContractEndpointSelectorForContractAddress(
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

    public func setCurrentSCOwnerAddress(owner: Data) {
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
    
    func shouldContinueExecutionAfterError(
        executionType: TransactionContainerExecutionType,
        pendingAsyncExecutions: [AsyncCallInput]
    ) -> Bool {
        switch executionType {
        case .sync:
            return false
        case .async:
            return true
        case .callback:
            return true
        }
    }
    
    func executePendingAsyncExecution(execution: AsyncCallInput) -> AsyncCallInput? {
        let executionType: TransactionContainerExecutionType = if let callbackClosure = execution.callbackClosure {
            .callback(
                arguments: execution.input.arguments,
                callbackClosure: callbackClosure
            )
        } else {
            .async
        }
        
        var asyncError: TransactionError? = nil
        
        let outputs = TransactionOutput()
        var executionResults: [Data]?
        do {
            asyncError = try self.runTransactions(
                transactionInput: execution.input,
                transactionOutput: outputs,
                executionType: executionType,
                operations: UncheckedClosure({
                    executionResults = self.transactionContainer?
                        .performNestedContractCall(
                            receiver: execution.input.contractAddress,
                            function: execution.function,
                            inputs: execution.input,
                            shouldBePerformedInAChildContainer: false
                        )
                })
             ).asyncError
        } catch {
            fatalError("Should not be executed, as runTransactions doesn't throw when performing non-sync executions")
        }
        
        var isError: Bool
        var asyncCallResults: [Data] = []
        
        if let asyncError = asyncError {
            var errorCodeEncoded = Buffer()
            asyncError.code.topEncode(output: &errorCodeEncoded)
            asyncCallResults.append(Data(errorCodeEncoded.toBytes()))
            
            asyncCallResults.append(Data(asyncError.message.utf8))
            
            isError = true
        } else {
            var crossShardSuccessCodeEncoded = Buffer()
            CROSS_SHARD_SUCCESS_CODE.topEncode(output: &crossShardSuccessCodeEncoded)
            asyncCallResults.append(Data(crossShardSuccessCodeEncoded.toBytes()))
            
            if let executionResults = executionResults {
                asyncCallResults.append(contentsOf: executionResults)
            }
            
            isError = false
        }
        
        if let successCallback = execution.successCallback,
           !isError
        {
            return AsyncCallInput(
                function: successCallback.function,
                input: TransactionInput(
                    contractAddress: execution.input.callerAddress,
                    callerAddress: execution.input.contractAddress,
                    egldValue: 0,
                    esdtValue: [],
                    arguments: asyncCallResults
                ),
                callbackClosure: successCallback.args,
                successCallback: nil,
                errorCallback: nil
            )
        }
        
        if let errorCallback = execution.errorCallback,
           isError
        {
            return AsyncCallInput(
                function: errorCallback.function,
                input: TransactionInput(
                    contractAddress: execution.input.callerAddress,
                    callerAddress: execution.input.contractAddress,
                    egldValue: 0,
                    esdtValue: [],
                    arguments: asyncCallResults
                ),
                callbackClosure: errorCallback.args,
                successCallback: nil,
                errorCallback: nil
            )
        }
        
        return nil
    }
    
    public func getNextHandle() -> Int32 {
        self.getCurrentContainer().getNextHandle()
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
        
        currentContainer.addOutput(output: outputData)
        
        return 0
    }
    
    public func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32 {
        let bigUint = self.getCurrentContainer().getBigUintData(handle: bigIntHandle)
        
        self.getCurrentContainer().managedBuffersData[bufferHandle] = bigUint.serialize()
        
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
    
    public func bufferGetArgument(argId: Int32, bufferHandle: Int32) -> Int32 {
        let currentContainer = self.getCurrentContainer()
        let arguments = currentContainer.getEndpointInputArguments()
        
        guard argId < arguments.count else {
            self.throwExecutionFailed(reason: "Argument out of range.") // TODO: use the same message as the WASM VM
        }
        
        let data = arguments[Int(argId)]
        
        currentContainer.managedBuffersData[bufferHandle] = data
        
        return 0
    }
    
    public func managedGetCallbackClosure(callbackClosureHandle: Int32) {
        let currentContainer = self.getCurrentContainer()
        
        switch currentContainer.executionType {
        case .callback(_, let callbackClosure):
            currentContainer.managedBuffersData[callbackClosureHandle] = callbackClosure
        default:
            self.throwExecutionFailed(reason: "Callback cannot be called directly") // TODO: use the same error as in the SpaceVM
        }
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
    
    public func getBlockEpoch() -> Int64 {
        fatalError() // TODO: implement and test
    }
    
    public func managedGetBlockRandomSeed(resultHandle: Int32) {
        fatalError() // TODO: implement and test
    }
    
    public func managedGetOriginalTxHash(resultHandle: Int32) {
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
    
    public func getShardOfAddress(addressPtr: UnsafeRawPointer) -> Int32 {
        let addressData: [UInt8] = Array(Data(bytes: addressPtr, count: 32))
        let metachainPrefix: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        let pubKeyPrefix = Array(addressData[0..<metachainPrefix.count])
        
        let metachainShardId: Int32 = Int32(bitPattern: 4294967295)
        if pubKeyPrefix == metachainPrefix {
            return metachainShardId
        }
        
        let zeroAddress: [UInt8] = Array(repeating: 0, count: 32)
        
        if addressData == zeroAddress {
            return metachainShardId
        }
        
        let n = Int32(ceil(log2(Float(self.numberOfShards))))
        let maskHigh: Int32 = (1 << n) - 1
        let maskLow: Int32 = (1 << (n - 1)) - 1
        
        let lastByteOfPubKey = Int32(addressData[addressData.count - 1])
        
        var shard = lastByteOfPubKey & maskHigh
        if shard > self.numberOfShards - 1 {
            shard = lastByteOfPubKey & maskLow
        }
        
        return shard
    }
}

extension DummyApi: CallValueApiProtocol {
    public func bigIntGetCallValue(dest: Int32) {
        let value = self.getCurrentContainer().getEgldValue()

        self.getCurrentContainer().managedBigIntData[dest] = value
    }

    public func managedGetMultiESDTCallValue(resultHandle: Int32) {
        let payments = self.getCurrentContainer().getEsdtValue()

        var array: Vector<TokenPayment> = []
        for payment in payments {
            array = array.appended(
                TokenPayment.new(
                    tokenIdentifier: Buffer(data: Array(payment.tokenIdentifier)),
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
        
        var tokenTransfersBufferInput = BufferNestedDecodeInput(buffer: Buffer(handle: tokenTransfersHandle).clone())
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
        
        let argumentsArray: Vector<Buffer> = Vector(handle: argumentsHandle)
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
        
        var resultsArray: Vector<Buffer> = Vector()
        
        for result in results {
            resultsArray = resultsArray.appended(Buffer(data: Array(result)))
        }
        
        currentTransactionContainer.managedBuffersData[resultHandle] = Data(resultsArray.buffer.toBytes())
        
        return 0
    }
    
    public func managedCreateAsyncCall(
        dstHandle: Int32,
        valueHandle: Int32,
        functionHandle: Int32,
        argumentsHandle: Int32,
        successOffset: UnsafeRawPointer,
        successLength: Int32,
        errorOffset: UnsafeRawPointer,
        errorLength: Int32,
        gas: Int64,
        extraGasForCallback: Int64,
        callbackClosureHandle: Int32
    ) -> Int32 {
        // TODO: implement and test
        let currentTransactionContainer = self.getCurrentContainer()
        
        let sender = currentTransactionContainer.getCurrentSCAccount().addressData
        let receiver = currentTransactionContainer.getBufferData(handle: dstHandle)
        let value = currentTransactionContainer.getBigIntData(handle: valueHandle)
        let function = currentTransactionContainer.getBufferData(handle: functionHandle)
        
        let argumentsArray: Vector<Buffer> = Vector(handle: argumentsHandle)
        var arguments: [Data] = []
        
        argumentsArray.forEach { arguments.append(Data($0.toBytes())) }
        
        var successCallback: AsyncCallCallbackInput? = nil
        if successLength > 0 {
            let successFunction = Data(bytes: successOffset, count: Int(successLength))
            let callbackClosure = currentTransactionContainer.getBufferData(handle: callbackClosureHandle)
            
            successCallback = AsyncCallCallbackInput(
                function: successFunction,
                args: callbackClosure
            )
        }
        
        var errorCallback: AsyncCallCallbackInput? = nil
        if errorLength > 0 {
            let successFunction = Data(bytes: errorOffset, count: Int(errorLength))
            let callbackClosure = currentTransactionContainer.getBufferData(handle: callbackClosureHandle)
            
            errorCallback = AsyncCallCallbackInput(
                function: successFunction,
                args: callbackClosure
            )
        }
        
        currentTransactionContainer.registerAsyncCallPromise(
            function: function,
            input: TransactionInput(
                contractAddress: receiver,
                callerAddress: sender,
                egldValue: value,
                esdtValue: [], // TODO: implement and test
                arguments: arguments
            ),
            successCallback: successCallback,
            errorCallback: errorCallback
        )
        
        return 0
    }
    
    public func managedDeployFromSourceContract(
        gas: Int64,
        valueHandle: Int32,
        addressHandle: Int32,
        codeMetadataHandle: Int32,
        argumentsHandle: Int32,
        resultAddressHandle: Int32,
        resultHandle: Int32
    ) -> Int32 {
        fatalError() // TODO: implement and test
    }
    
    public func managedUpgradeFromSourceContract(
        dstHandle: Int32,
        gas: Int64,
        valueHandle: Int32,
        addressHandle: Int32,
        codeMetadataHandle: Int32,
        argumentsHandle: Int32,
        resultHandle: Int32
    ) {
        fatalError() // TODO: implement and test
    }
    
    public func cleanReturnData() {
        // TODO: this opcode seems to not be relevant in the current state of the SwiftVM. I have to investigate a bit more on it.
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
    
    public func managedSha256(inputHandle: Int32, outputHandle: Int32) -> Int32 {
        fatalError() // TODO: implement and test
    }
}
#endif
