#if !WASM
import Foundation
import BigInt

package class TransactionContainer {
    package var managedBuffersData: [Int32 : Data] = [:]
    package var managedBigIntData: [Int32 : BigInt] = [:]
    package var storageForContractAddress: [String : [Data : Data]] = [:]
    public package(set) var errorMessage: String? = nil
    
    package var currentContractAddress: String? = nil
    
    package init(
        worldState: WorldState?,
        currentContractAddress: String
    ) {
        if let worldState = worldState {
            self.storageForContractAddress = worldState.storageForContractAddress
        }
        
        self.currentContractAddress = currentContractAddress
    }
    
    package init() {}
    
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
    
    package func getCurrentContractAddress() -> String {
        guard let currentContractAddress = self.currentContractAddress else {
            fatalError("No current contract address. Are you in a transaction context?")
        }
        
        return currentContractAddress
    }
    
    package func getStorageForCurrentContractAddress() -> [Data : Data] {
        let currentContractAddress = self.getCurrentContractAddress()
        
        return self.storageForContractAddress[currentContractAddress] ?? [:]
    }
    
    package func setStorageForCurrentContractAddress(storage: [Data : Data]) {
        let currentContractAddress = self.getCurrentContractAddress()
        
        self.storageForContractAddress[currentContractAddress] = storage
    }
}

#endif
