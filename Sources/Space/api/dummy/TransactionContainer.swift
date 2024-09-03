#if !WASM
import Foundation
import BigInt

package enum TransactionContainerErrorBehavior {
    case blockThread
    case fatalError
}

package final class TransactionContainer: @unchecked Sendable {
    package var managedBuffersData: [Int32 : Data] = [:]
    package var managedBigIntData: [Int32 : BigInt] = [:]
    package var state: WorldState
    package var outputs: [Data] = []
    public package(set) var error: TransactionError? = nil
    public package(set) var shouldExitThread: Bool = false
    
    
    // If nestedCallTransactionContainer != nil, then nestedCallTransactionContainer.parent == self
    package weak var parentContainer: TransactionContainer? = nil
    package var nestedCallTransactionContainer: TransactionContainer? = nil
    
    private var transactionInput: TransactionInput? = nil
    package private(set) var transactionOutput: TransactionOutput? = nil
    private var errorBehavior: TransactionContainerErrorBehavior
    
    package init(
        worldState: WorldState,
        transactionInput: TransactionInput,
        errorBehavior: TransactionContainerErrorBehavior
    ) {
        self.state = worldState
        self.transactionInput = transactionInput
        self.transactionOutput = TransactionOutput()
        self.errorBehavior = errorBehavior
    }
    
    package init(errorBehavior: TransactionContainerErrorBehavior) {
        self.errorBehavior = errorBehavior
        self.state = WorldState()
    }
    
    package func throwError(error: TransactionError) -> Never {
        // TODO: change logs to only have signalError or nothing
        
        switch self.errorBehavior {
        case .fatalError:
            fatalError(error.message)
        case .blockThread:
            self.error = error
            
            if let parentContainer = self.parentContainer {
                parentContainer.throwError(error: .executionFailed(reason: "execution failed"))
            } else {
                // Wait for the error to be handled from an external process, as we don't want any further instruction to be executed
                // This container should not be used anymore
                while true {
                    if self.shouldExitThread {
                        Thread.exit()
                    }
                }
            }
        }
    }
    
    package func registerContractEndpointSelectorForContractAccount(
        contractAddress: Data,
        selector: any ContractEndpointSelector
    ) {
        let contractAccount = self.getAccount(address: contractAddress)
        
        self.state.addContractEndpointSelectorForContractAccount(
            contractAccount: contractAccount,
            selector: selector
        )
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
    
    package func getTransactionInput() -> TransactionInput {
        guard let input = self.transactionInput else {
            self.throwError(error: .worldError(message: "No transaction input provided. Are you in a transaction context?"))
        }
        
        return input
    }
    
    private func getContractEndpointSelectorForContractAccount(contractAccount: WorldAccount) -> any ContractEndpointSelector {
        guard let selector = self.state.contractEndpointSelectorForContractAddress[contractAccount.addressData] else {
            self.throwError(error: .worldError(message: "Contract not registered for address: \(contractAccount.addressData.hexEncodedString())"))
        }
        
        return selector
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
    
    public func performNestedContractCall(
        receiver: Data,
        function: Data,
        inputs: TransactionInput
    ) -> [Data] {
        self.performEgldOrEsdtTransfers(
            senderAddress: inputs.callerAddress,
            receiverAddress: receiver,
            egldValue: inputs.egldValue,
            esdtValue: inputs.esdtValue
        )
        
        let endpointName = String(data: function, encoding: .utf8)!
        let receiverAccount = self.getAccount(address: receiver)
        var selector = self.getContractEndpointSelectorForContractAccount(contractAccount: receiverAccount)
        
        let nestedCallTransactionContainer = TransactionContainer(
            worldState: self.state,
            transactionInput: inputs,
            errorBehavior: self.errorBehavior
        )
        nestedCallTransactionContainer.parentContainer = self
        self.nestedCallTransactionContainer = nestedCallTransactionContainer
        
        selector._callEndpoint(name: endpointName)
        
        let outputData = nestedCallTransactionContainer.outputs
        self.state = nestedCallTransactionContainer.state
        
        self.nestedCallTransactionContainer = nil
        
        return outputData
    }
    
    private func addEsdtToAddressBalance(address: Data, token: Data, nonce: UInt64, value: BigInt) {
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
    
    package func writeLog(topicsHandle: Int32, dataHandle: Int32) {
        let topicsArray: Vector<Buffer> = Vector(buffer: Buffer(data: Array(self.getBufferData(handle: topicsHandle))))
        let data = self.getBufferData(handle: dataHandle)
        
        var topics: [Data] = []
        
        topicsArray.forEach { topics.append(Data($0.toBytes())) }
        
        self.transactionOutput?.writeLog(log: TransactionOutputLogRaw(topics: topics, data: data))
    }
}

#endif
