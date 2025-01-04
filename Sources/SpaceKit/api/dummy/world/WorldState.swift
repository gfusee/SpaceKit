#if !WASM
import Foundation
import BigInt

package struct WorldState {
    package var storageForContractAddress: [Data : [Data : Data]] = [:] // TODO: set the setter private
    package private(set) var accounts: [WorldAccount] = []
    package private(set) var registeredTokens: [Data : TokenProperties] = [:]
    
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
    
    package mutating func registerToken(
        tokenIdentifier: Data,
        properties: TokenProperties
    ) {
        self.registeredTokens[tokenIdentifier] = properties
    }
    
    package func getNextRandomTokenIdentifier(for ticker: Data) -> Data {
        var counter: Int = 0

        while true {
            // Convert the counter to a hexadecimal string
            let randomString = String(format: "%06x", counter)
            
            guard let dashData = "-".data(using: .utf8) else { fatalError("Failed to create dash data") }
            let candidateName = ticker + dashData + randomString.data(using: .utf8)!
            
            if self.registeredTokens[candidateName] == nil {
                return candidateName
            }

            counter += 1
        }
    }
    
    public init() {}
}

#endif
