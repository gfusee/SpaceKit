#if !WASM
import Foundation
import BigInt

package struct WorldState {
    package var storageForContractAddress: [Data : [Data : Data]] = [:] // TODO: set the setter private
    package private(set) var accounts: [WorldAccount] = []
    
    public func getAccount(addressData: Data) -> WorldAccount? {
        return self.accounts.first { $0.addressData == addressData }
    }
    
    package mutating func setAccounts(accounts: [WorldAccount]) {
        for account in accounts {
            self.setAccount(account: account)
        }
    }
    
    package mutating func setAccount(account: WorldAccount) {
        var accounts = self.accounts.filter { $0.addressData != account.addressData }
        accounts.append(account)
        
        self.accounts = accounts
    }
}

#endif
