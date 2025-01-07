#if !WASM
import Foundation
import BigInt

package let esdtSystemContractAddress = "000000000000000000010000000000000000000000000000000000000002ffff".hexadecimal

package struct WorldState {
    package var storageForContractAddress: [Data : [Data : Data]] = [:] // TODO: set the setter private
    package private(set) var accounts: [WorldAccount] = [
        WorldAccount(
            address: "000000000000000000010000000000000000000000000000000000000002ffff".hexadecimal,
            controllers: [
                ESDTSystemContract.self
            ]
        )
    ]
    package private(set) var registeredTokens: [Data : TokenProperties] = [:]
    package private(set) var tokenTypeForToken: [Data : TokenType] = [:]
    
    // First key = token identifier, nested key = address
    package private(set) var tokenRolesForAddress: [Data : [Data : EsdtLocalRoles]] = [:]
    package private(set) var nextNonceForNonFungibleToken: [Data : UInt64] = [:]
    package private(set) var managerForToken: [Data : Data] = [:]
    
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
    
    package mutating func getAddressTokenRoles(
        tokenIdentifier: Data,
        address: Data
    ) -> EsdtLocalRoles {
        if let rolesForAddressMap = self.tokenRolesForAddress[tokenIdentifier] {
            if let addressRoles = rolesForAddressMap[address] {
                return addressRoles
            }
        }
        
        return EsdtLocalRoles()
    }
    
    package mutating func setTokenRoles(
        tokenIdentifier: Data,
        address: Data,
        roles: EsdtLocalRoles
    ) {
        var rolesForAddressMap = self.tokenRolesForAddress[tokenIdentifier] ?? [:]
        
        rolesForAddressMap[address] = roles
        
        self.tokenRolesForAddress[tokenIdentifier] = rolesForAddressMap
    }
    
    package mutating func registerToken(
        managerAddress: Data,
        tokenIdentifier: Data,
        tokenType: TokenType,
        properties: TokenProperties
    ) {
        self.managerForToken[tokenIdentifier] = managerAddress
        self.tokenTypeForToken[tokenIdentifier] = tokenType
        self.registeredTokens[tokenIdentifier] = properties
    }
    
    package mutating func createNewNonFungibleNonce(
        tokenIdentifier: Data
    ) -> UInt64 {
        let newNonce = self.nextNonceForNonFungibleToken[tokenIdentifier] ?? 1
        
        self.nextNonceForNonFungibleToken[tokenIdentifier] = newNonce + 1
        
        return newNonce
    }
    
    package func getTokenManagerAddress(
        tokenIdentifier: Data
    ) -> Data? {
        self.managerForToken[tokenIdentifier]
    }
    
    package func getTokenType(
        tokenIdentifier: Data
    ) -> TokenType? {
        self.tokenTypeForToken[tokenIdentifier]
    }
    
    package func getTokenProperties(
        tokenIdentifier: Data
    ) -> TokenProperties? {
        self.registeredTokens[tokenIdentifier]
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
