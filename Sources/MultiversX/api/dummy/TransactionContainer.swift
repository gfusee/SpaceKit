#if !WASM
import Foundation
import BigInt

package enum TransactionContainerErrorBehavior {
    case blockThread
    case fatalError
}

package struct TransactionInput {
    let contractAddress: Data
    let callerAddress: Data
    let egldValue: BigInt
}

package class TransactionContainer {
    package var managedBuffersData: [Int32 : Data] = [:]
    package var managedBigIntData: [Int32 : BigInt] = [:]
    package var state: WorldState
    public package(set) var error: TransactionError? = nil
    public package(set) var shouldExitThread: Bool = false
    
    private var transactionInput: TransactionInput? = nil
    private var errorBehavior: TransactionContainerErrorBehavior
    
    package init(
        worldState: WorldState,
        transactionInput: TransactionInput,
        errorBehavior: TransactionContainerErrorBehavior
    ) {
        self.state = worldState
        self.transactionInput = transactionInput
        self.errorBehavior = errorBehavior
    }
    
    package init(errorBehavior: TransactionContainerErrorBehavior) {
        self.errorBehavior = errorBehavior
        self.state = WorldState()
    }
    
    package func throwError(error: TransactionError) -> Never {
        switch self.errorBehavior {
        case .fatalError:
            fatalError(error.message)
        case .blockThread:
            self.error = error
            
            // Wait for the error to be handled from an external process, and we don't want any further instruction to be executed
            // This container should not be used anymore
            while true {
                if self.shouldExitThread {
                    Thread.exit()
                }
            }
        }
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
    
    package func getStorageForCurrentContractAddress() -> [Data : Data] {
        let currentContractAddress = self.getCurrentContractAddress()
        
        return self.state.storageForContractAddress[currentContractAddress] ?? [:]
    }
    
    package func setStorageForCurrentContractAddress(storage: [Data : Data]) {
        let currentContractAddress = self.getCurrentContractAddress()
        
        self.state.storageForContractAddress[currentContractAddress] = storage
    }

    public func performEgldTransfer(from: Data, to: Data, value: BigInt) {
        self.addEgldToAddressBalance(address: from, value: -value)
        self.addEgldToAddressBalance(address: to, value: value)
    }
    
    private func addEgldToAddressBalance(address: Data, value: BigInt) {
        var account = self.getAccount(address: address)
        let newBalance = account.balance + value
        
        guard newBalance >= 0 else {
            fatalError()
        }
        
        account.balance = newBalance
        
        self.state.setAccount(account: account)
    }

    public func performEsdtTransfer(from: Data, to: Data, token: Data, nonce: UInt64, value: BigInt) {
        self.addEsdtToAddressBalance(address: from, token: token, nonce: nonce, value: -value)
        self.addEsdtToAddressBalance(address: to, token: token, nonce: nonce, value: value)
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
}

#endif
