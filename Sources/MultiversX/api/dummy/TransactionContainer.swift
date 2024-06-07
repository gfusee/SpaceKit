#if !WASM
import Foundation
import BigInt

package class TransactionContainer {
    package var managedBuffersData: [Int32 : Data] = [:]
    package var managedBigIntData: [Int32 : BigInt] = [:]
    package var state: WorldState
    public package(set) var error: TransactionError? = nil
    
    private var currentContractAddress: Data? = nil
    
    package init(
        worldState: WorldState,
        currentContractAddress: String
    ) {
        self.currentContractAddress = currentContractAddress.toAddressData()
        self.state = worldState
    }
    
    package init() {
        self.state = WorldState()
    }
    
    private func getAccount(address: Data) -> WorldAccount {
        guard let account = self.state.getAccount(addressData: address) else {
            fatalError() // TODO: handle errors in the container
        }
        
        return account
    }
    
    package func getBufferData(handle: Int32) -> Data {
        guard let data = self.managedBuffersData[handle] else {
            fatalError("Buffer handle not found")
        }
        
        return data
    }
    
    package func getBigIntData(handle: Int32) -> BigInt {
        guard let data = self.managedBigIntData[handle] else {
            fatalError("Big integer handle not found")
        }
        
        return data
    }
    
    private func getCurrentContractAddress() -> Data {
        guard let currentContractAddress = self.currentContractAddress else {
            fatalError("No current contract address. Are you in a transaction context?")
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
