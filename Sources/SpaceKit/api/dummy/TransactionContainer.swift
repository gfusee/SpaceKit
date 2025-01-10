#if !WASM
import Foundation
import BigInt

package enum TransactionContainerErrorBehavior {
    case blockThread
    case fatalError
}

public enum TransactionContainerExecutionType {
    case sync // default
    case async // the async execution on the called contract
    case callback(arguments: [Data], callbackClosure: Data)
}

package final class TransactionContainer: @unchecked Sendable {
    package var managedBuffersData: [Int32 : Data] = [:]
    package var managedBigIntData: [Int32 : BigInt] = [:]
    package var state: WorldState
    package private(set) var outputs: [Data] = []
    public package(set) var error: TransactionError? = nil
    public package(set) var shouldExitThread: Bool = false
    
    
    // If nestedCallTransactionContainer != nil, then nestedCallTransactionContainer.parent == self
    package weak var parentContainer: TransactionContainer? = nil
    package var nestedCallTransactionContainer: TransactionContainer? = nil
    package private(set) var pendingAsyncExecutions: [AsyncCallInput] = []
    
    private var transactionInput: TransactionInput? = nil
    package private(set) var transactionOutput: TransactionOutput? = nil
    package private(set) var executionType: TransactionContainerExecutionType
    private var errorBehavior: TransactionContainerErrorBehavior
    private var nextHandle: Int32 = -100
    
    package init(
        worldState: WorldState,
        transactionInput: TransactionInput,
        executionType: TransactionContainerExecutionType,
        errorBehavior: TransactionContainerErrorBehavior,
        byTransferringDataFrom container: TransactionContainer?
    ) {
        self.state = worldState
        self.transactionInput = transactionInput
        self.transactionOutput = TransactionOutput()
        self.executionType = executionType
        self.errorBehavior = errorBehavior
        
        if let container = container {
            self.managedBuffersData = container.managedBuffersData
            self.managedBigIntData = container.managedBigIntData
            
            self.nextHandle = container.nextHandle
        }
    }
    
    package init(errorBehavior: TransactionContainerErrorBehavior) {
        self.errorBehavior = errorBehavior
        self.state = WorldState()
        self.executionType = .sync
        self.nextHandle = -100
    }
    
    package func throwError(error: TransactionError) -> Never {
        // TODO: change logs to only have signalError or nothing
        
        switch self.errorBehavior {
        case .fatalError:
            fatalError(error.message)
        case .blockThread:
            self.error = error
            
            if let parentContainer = self.parentContainer {
                if error.isUserError && self.getCurrentSCAccount().addressData == esdtSystemContractAddress {
                    parentContainer.throwError(error: .executionFailed(reason: error.message)) // TODO: Is it execution failed?
                }
                
                parentContainer.throwExecutionFailed()
            } else {
                // Wait for the error to be handled from an external process, as we don't want any further instruction to be executed
                // This container should not be used anymore
                while true {
                    if self.shouldExitThread {
                        Thread.exit()
                    }
                }
            }
            
        }
    }
    
    package func getNextHandle() -> Int32 {
        let currentHandle = self.nextHandle
        self.nextHandle -= 1

        return currentHandle
    }
    
    private func getAccount(address: Data) -> WorldAccount {
        guard let account = self.state.getAccount(addressData: address) else {
            self.throwError(error: .worldError(message: "Account not found: \(address.hexEncodedString())"))
        }
        
        return account
    }
    
    package func getBufferData(handle: Int32) -> Data {
        guard let data = self.managedBuffersData[handle] else {
            self.throwError(error: .executionFailed(reason: "no managed buffer under the given handle"))
        }
        
        return data
    }
    
    package func getBigIntData(handle: Int32) -> BigInt {
        guard let data = self.managedBigIntData[handle] else {
            self.throwError(error: .executionFailed(reason: "no bigInt under the given handle"))
        }
        
        return data
    }
    
    package func getBigUintData(handle: Int32) -> BigUInt {
        guard let data = self.managedBigIntData[handle] else {
            self.throwError(error: .executionFailed(reason: "no bigInt under the given handle"))
        }
        
        return BigUInt.init(data)
    }
    
    package func getTransactionInput() -> TransactionInput {
        guard let input = self.transactionInput else {
            self.throwError(error: .worldError(message: "No transaction input provided. Are you in a transaction context?"))
        }
        
        return input
    }
    
    private func getContractEndpointSelectorForContractAccount(contractAccount: WorldAccount) -> any ContractEndpointSelector {
        guard let selector = contractAccount.controllers else {
            self.throwError(error: .worldError(message: "Contract not registered for address: \(contractAccount.addressData.hexEncodedString())"))
        }
        
        return selector as [ContractEndpointSelector.Type]
    }
    
    private func getCurrentContractAddress() -> Data {
        self.getTransactionInput().contractAddress
    }
    
    private func getCurrentCallerAddress() -> Data {
        self.getTransactionInput().callerAddress
    }
    
    package func getCurrentSCAccount() -> WorldAccount {
        let address = self.getCurrentContractAddress()
        
        return self.getAccount(address: address)
    }

    package func getCurrentSCOwnerAccount() -> WorldAccount {
        guard let ownerAddress = self.getCurrentSCAccount().owner else {
            self.throwError(error: .worldError(message: "No owner set for the contract account."))
        }

        let ownerAccount = self.getAccount(address: ownerAddress)
        
        return ownerAccount
    }

    package func setCurrentSCOwnerAddress(owner: Data) {
        var scAccount = self.getCurrentSCAccount()

        scAccount.owner = owner

        self.state.setAccount(account: scAccount)
    }
    
    package func getCurrentCallerAccount() -> WorldAccount {
        let address = self.getCurrentCallerAddress()
        
        return self.getAccount(address: address)
    }

    package func getEgldValue() -> BigInt {
        return self.getTransactionInput().egldValue
    }

    package func getEsdtValue() -> [TransactionInput.EsdtPayment] {
        return self.getTransactionInput().esdtValue
    }
    
    package func getEndpointInputArguments() -> [Data] {
        return self.getTransactionInput().arguments
    }
    
    package func getStorageForCurrentContractAddress() -> [Data : Data] {
        let currentContractAddress = self.getCurrentContractAddress()
        
        return self.state.storageForContractAddress[currentContractAddress] ?? [:]
    }
    
    package func setStorageForCurrentContractAddress(storage: [Data : Data]) {
        let currentContractAddress = self.getCurrentContractAddress()
        
        self.state.storageForContractAddress[currentContractAddress] = storage
    }
    
    package func addOutput(output: Data) {
        self.outputs.append(output)
        
        if let transactionInput = transactionInput,
           let transactionOutput = transactionOutput {
            if var lastResults = transactionOutput.results.last,
               lastResults.contractAddress == transactionInput.contractAddress
            {
                lastResults.results.append(output)
                transactionOutput.results[transactionOutput.results.count] = lastResults
            } else {
                transactionOutput.results.append(
                    TransactionOutputResult(
                        contractAddress: transactionInput.contractAddress,
                        results: [output]
                    )
                )
            }
        }
    }

    package func performEgldTransfer(from: Data, to: Data, value: BigInt) {
        self.addEgldToAddressBalance(address: from, value: -value)
        self.addEgldToAddressBalance(address: to, value: value)
    }
    
    package func performEgldOrEsdtTransfers(
        senderAddress: Data,
        receiverAddress: Data,
        egldValue: BigInt,
        esdtValue: [TransactionInput.EsdtPayment]
    ) {
        if egldValue > 0 {
            guard esdtValue.isEmpty else {
                self.throwError(error: .executionFailed(reason: "cannot have both egld and esdt value")) // TODO: use the same error message as the SpaceVM
            }

            self.performEgldTransfer(
                from: senderAddress,
                to: receiverAddress,
                value: egldValue
            )
        } else {
            for value in esdtValue {
                self.performEsdtTransfer(
                    from: senderAddress,
                    to: receiverAddress,
                    token: value.tokenIdentifier,
                    nonce: value.nonce,
                    value: value.amount
                )
            }
        }
    }
    
    private func addEgldToAddressBalance(address: Data, value: BigInt) {
        var account = self.getAccount(address: address)
        let newBalance = account.balance + value
        
        guard newBalance >= 0 else {
            self.throwError(error: .executionFailed(reason: "insufficient balance")) // TODO: use the same error as the WASM VM
        }
        
        account.balance = newBalance
        
        self.state.setAccount(account: account)
    }

    public func performEsdtTransfer(from: Data, to: Data, token: Data, nonce: UInt64, value: BigInt) {
        self.addEsdtToAddressBalance(address: from, token: token, nonce: nonce, value: -value)
        self.addEsdtToAddressBalance(address: to, token: token, nonce: nonce, value: value)
    }
    
    public func registerAsyncCallPromise(
        function: Data,
        input: TransactionInput,
        successCallback: AsyncCallCallbackInput?,
        errorCallback: AsyncCallCallbackInput?
    ) {
        self.pendingAsyncExecutions.append(
            AsyncCallInput(
                function: function,
                input: input,
                callbackClosure: nil,
                successCallback: successCallback,
                errorCallback: errorCallback
            )
        )
    }
    
    public func performNestedContractCall(
        receiver: Data,
        function: Data,
        inputs: TransactionInput,
        shouldBePerformedInAChildContainer: Bool = true // useful for async calls, see DummyApi's executePendingAsyncExecution
    ) -> [Data] {
        let endpointName = String(data: function, encoding: .utf8)!
        let receiverAccount = self.getAccount(address: receiver)
        var selector = self.getContractEndpointSelectorForContractAccount(contractAccount: receiverAccount)
        
        if shouldBePerformedInAChildContainer {
            self.performEgldOrEsdtTransfers(
                senderAddress: inputs.callerAddress,
                receiverAddress: receiver,
                egldValue: inputs.egldValue,
                esdtValue: inputs.esdtValue
            )
            
            let nestedCallTransactionContainer = TransactionContainer(
                worldState: self.state,
                transactionInput: inputs,
                executionType: executionType,
                errorBehavior: self.errorBehavior,
                byTransferringDataFrom: nil
            )
            nestedCallTransactionContainer.parentContainer = self
            self.nestedCallTransactionContainer = nestedCallTransactionContainer
        }
        
        guard selector._callEndpoint(name: endpointName) else {
            API.throwFunctionNotFoundError()
        }
        
        if shouldBePerformedInAChildContainer {
            guard let nestedCallTransactionContainer = self.nestedCallTransactionContainer else {
                fatalError("Should not be executed")
            }
            
            let outputData = nestedCallTransactionContainer.outputs
            self.state = nestedCallTransactionContainer.state
            
            self.nestedCallTransactionContainer = nil
            
            return outputData
        } else {
            return self.outputs
        }
    }
    
    package func addEsdtToAddressBalance(address: Data, token: Data, nonce: UInt64, value: BigInt) {
        var account = self.getAccount(address: address)
        var allBalances = account.esdtBalances[token] ?? []
        var tokenBalance = EsdtBalance(nonce: nonce, balance: 0)
        
        for (balanceIndex, balance) in allBalances.enumerated() {
            if balance.nonce == nonce {
                tokenBalance = balance
                allBalances.remove(at: balanceIndex)
                
                break
            }
        }
        
        tokenBalance.balance += value
        
        guard tokenBalance.balance >= 0 else {
            fatalError()
        }
        
        allBalances.append(tokenBalance)
        account.esdtBalances[token] = allBalances
        
        self.state.setAccount(account: account)
    }
    
    package func removeEsdtFromAddressBalance(
        address: Data,
        token: Data,
        nonce: UInt64,
        value: BigInt
    ) {
        var account = self.getAccount(address: address)
        var allBalances = account.esdtBalances[token] ?? []
        var tokenBalance = EsdtBalance(nonce: nonce, balance: 0)
        
        for (balanceIndex, balance) in allBalances.enumerated() {
            if balance.nonce == nonce {
                tokenBalance = balance
                allBalances.remove(at: balanceIndex)
                
                break
            }
        }
        
        tokenBalance.balance -= value
        
        guard tokenBalance.balance >= 0 else {
            fatalError()
        }
        
        allBalances.append(tokenBalance)
        account.esdtBalances[token] = allBalances
        
        self.state.setAccount(account: account)
    }

    package func writeLog(topicsHandle: Int32, dataHandle: Int32) {
        let topicsArray: Vector<Buffer> = Vector(buffer: Buffer(data: Array(self.getBufferData(handle: topicsHandle))))
        let data = self.getBufferData(handle: dataHandle)
        
        var topics: [Data] = []
        
        topicsArray.forEach { topics.append(Data($0.toBytes())) }
        
        self.transactionOutput?.writeLog(log: TransactionOutputLogRaw(topics: topics, data: data))
    }
    
    // Avoid a wrong warning about infinite recursion
    private func throwExecutionFailed(message: String = "execution failed") -> Never {
        self.throwError(error: .executionFailed(reason: message))
    }
    
    package func getTokenManagerAddress(
        tokenIdentifier: Data
    ) -> Data? {
        self.state.getTokenManagerAddress(tokenIdentifier: tokenIdentifier)
    }
    
    package func getTokenType(
        tokenIdentifier: Data
    ) -> TokenType? {
        self.state.getTokenType(tokenIdentifier: tokenIdentifier)
    }

    package func getTokenProperties(
        tokenIdentifier: Data
    ) -> TokenProperties? {
        self.state.getTokenProperties(tokenIdentifier: tokenIdentifier)
    }
    
    package func registerToken(
        caller: Data,
        managerAddress: Data,
        ticker: Data,
        initialSupply: BigInt,
        tokenType: TokenType,
        properties: TokenProperties
    ) -> Data {
        let newTokenIdentifier = self.state.getNextRandomTokenIdentifier(for: ticker)
        
        self.state
            .registerToken(
                managerAddress: managerAddress,
                tokenIdentifier: newTokenIdentifier,
                tokenType: tokenType,
                properties: properties
            )
        
        if initialSupply > 0 {
            self.addEsdtToAddressBalance(
                address: caller,
                token:  newTokenIdentifier,
                nonce: 0,
                value: initialSupply
            )
        }
        
        return newTokenIdentifier
    }
    
    package func mintTokens(
        caller: Data,
        tokenIdentifier: Data,
        nonce: UInt64,
        amount: BigInt
    ) {
        if amount > 0 {
            self.addEsdtToAddressBalance(
                address: caller,
                token: tokenIdentifier,
                nonce: nonce,
                value: amount
            )
        }
    }
    
    package func burnTokens(
        address: Data,
        tokenIdentifier: Data,
        nonce: UInt64,
        amount: BigInt
    ) {
        if amount > 0 {
            self.removeEsdtFromAddressBalance(
                address: address,
                token: tokenIdentifier,
                nonce: nonce,
                value: amount
            )
        }
    }
    
    package func doesNonFungibleNonceExist(
        tokenIdentifier: Data,
        nonce: UInt64
    ) -> Bool {
        self.state
            .doesNonFungibleNonceExist(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce
            )
    }
    
    package func createNewNonFungibleNonce(
        caller: Data,
        tokenIdentifier: Data,
        initialQuantity: BigInt,
        hash: Data,
        name: Data,
        attributes: Data,
        creator: Data,
        royalties: BigInt,
        uris: Data
    ) -> UInt64 {
        let newNonce = self.state.createNewNonFungibleNonce(
            tokenIdentifier: tokenIdentifier,
            amount: initialQuantity,
            hash: hash,
            name: name,
            attributes: attributes,
            creator: creator,
            royalties: royalties,
            uris: uris
        )
        
        if initialQuantity > 0 {
            self.addEsdtToAddressBalance(
                address: caller,
                token: tokenIdentifier,
                nonce: newNonce,
                value: initialQuantity
            )
        }
        
        return newNonce
    }
    
    package func setAddressTokenRoles(
        tokenIdentifier: Data,
        address: Data,
        roles: EsdtLocalRoles
    ) {
        var addressRoles = self.state.getAddressTokenRoles(
            tokenIdentifier: tokenIdentifier,
            address: address
        )
        
        addressRoles.addRoles(roles: roles)
        
        self.state.setTokenRoles(
            tokenIdentifier: tokenIdentifier,
            address: address,
            roles: addressRoles
        )
    }
    
    package func setTokenData(
        tokenIdentifier: Data,
        nonce: UInt64,
        data: WorldState.TokenData
    ) {
        self.state.setTokenData(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            data: data
        )
    }

    package func getTokenData(
        tokenIdentifier: Data,
        nonce: UInt64
    ) -> WorldState.TokenData? {
        self.state.getTokenData(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
    }

    package func getAddressTokenRoles(
        tokenIdentifier: Data,
        address: Data
    ) -> EsdtLocalRoles {
        self.state.getAddressTokenRoles(
            tokenIdentifier: tokenIdentifier,
            address: address
        )
    }
}
#endif
