#if !WASM
import Foundation
import BigInt

package enum TransactionContainerErrorBehavior {
    case blockThread
    case fatalError
}

package class TransactionContainer {
    package var managedBuffersData: [Int32 : Data] = [:]
    package var managedBigIntData: [Int32 : BigInt] = [:]
    package var state: WorldState
    public package(set) var error: TransactionError? = nil
    public package(set) var shouldExitThread: Bool = false
    
    private var currentContractAddress: Data? = nil
    private var errorBehavior: TransactionContainerErrorBehavior
    
    package init(
        worldState: WorldState,
        currentContractAddress: String,
        errorBehavior: TransactionContainerErrorBehavior
    ) {
        self.errorBehavior = errorBehavior
        self.currentContractAddress = currentContractAddress.toAddressData()
        self.state = worldState
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
    
    private func getCurrentContractAddress() -> Data {
        guard let currentContractAddress = self.currentContractAddress else {
            self.throwError(error: .worldError(message: "No current contract address. Are you in a transaction context?"))
        }
        
        return currentContractAddress
    }
    
    package func getCurrentSCAccount() -> WorldAccount {
        let address = self.getCurrentContractAddress()
        
        return self.getAccount(address: address)
    }
    
    package func getStorageForCurrentContractAddress() -> [Data : Data] {
        let currentContractAddress = self.getCurrentContractAddress()
        
        return self.state.storageForContractAddress[currentContractAddress] ?? [:]
    }
    
    package func setStorageForCurrentContractAddress(storage: [Data : Data]) {
        let currentContractAddress = self.getCurrentContractAddress()
        
        self.state.storageForContractAddress[currentContractAddress] = storage
    }
    
    public func addEgldToAddressBalance(address: Data, value: BigInt) {
        var account = self.getAccount(address: address)
        let newBalance = account.balance + value
        
        guard newBalance >= 0 else {
            fatalError()
        }
        
        account.balance = newBalance
        
        self.state.setAccount(account: account)
    }
}

#endif
