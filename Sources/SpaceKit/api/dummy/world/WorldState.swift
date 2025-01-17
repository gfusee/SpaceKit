#if !WASM
import Foundation
import BigInt

private struct TokenIdentifierAndNonce: Hashable {
    let tokenIdentifier: Data
    let nonce: UInt64
}

package let esdtSystemContractAddress = "000000000000000000010000000000000000000000000000000000000002ffff".hexadecimal

package struct WorldState {
    package struct TokenData {
        let tokenType: TokenType
        let amount: BigInt
        let frozen: Bool
        let hash: Data
        let name: Data
        var attributes: Data
        let creator: Data
        var royalties: BigInt
        let uris: Data
    }
    
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
    package private(set) var numberOfAccountWithUpdateAttributesRoleForToken: [Data : UInt64] = [:]
    package private(set) var numberOfAccountWithModifyRoyaltiesRoleForToken: [Data : UInt64] = [:]
    package private(set) var nextNonceForNonFungibleToken: [Data : UInt64] = [:]
    package private(set) var managerForToken: [Data : Data] = [:]
    private var tokenDataForToken: [TokenIdentifierAndNonce : TokenData] = [:]
    
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
        let oldRoles = self.getAddressTokenRoles(tokenIdentifier: tokenIdentifier, address: address)
        
        if !oldRoles.contains(flag: .nftUpdateAttributes) && roles.contains(flag: .nftUpdateAttributes) {
            self.numberOfAccountWithUpdateAttributesRoleForToken[tokenIdentifier] = (self.numberOfAccountWithUpdateAttributesRoleForToken[tokenIdentifier] ?? 0) + 1
        } else if oldRoles.contains(flag: .nftUpdateAttributes) && !roles.contains(flag: .nftUpdateAttributes) {
            self.numberOfAccountWithUpdateAttributesRoleForToken[tokenIdentifier] = (self.numberOfAccountWithUpdateAttributesRoleForToken[tokenIdentifier] ?? 0) - 1
        }
        
        if !oldRoles.contains(flag: .modifyRoyalties) && roles.contains(flag: .modifyRoyalties) {
            self.numberOfAccountWithModifyRoyaltiesRoleForToken[tokenIdentifier] = (self.numberOfAccountWithModifyRoyaltiesRoleForToken[tokenIdentifier] ?? 0) + 1
        } else if oldRoles.contains(flag: .modifyRoyalties) && !roles.contains(flag: .modifyRoyalties) {
            self.numberOfAccountWithModifyRoyaltiesRoleForToken[tokenIdentifier] = (self.numberOfAccountWithModifyRoyaltiesRoleForToken[tokenIdentifier] ?? 0) - 1
        }
        
        var rolesForAddressMap = self.tokenRolesForAddress[tokenIdentifier] ?? [:]
        
        rolesForAddressMap[address] = roles
        
        self.tokenRolesForAddress[tokenIdentifier] = rolesForAddressMap
    }
    
    package mutating func setTokenData(
        tokenIdentifier: Data,
        nonce: UInt64,
        data: TokenData
    ) {
        let key = TokenIdentifierAndNonce(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
        
        self.tokenDataForToken[key] = data
    }
    
    package mutating func getNumberOfAddressesWithRolesForToken(
        tokenIdentifier: Data,
        roles: EsdtLocalRoles
    ) -> UInt64 {
        var result: UInt64 = 0
        
        roles.forEachFlag { flag in
            let numberToAdd = switch flag {
            case .nftUpdateAttributes:
                self.numberOfAccountWithUpdateAttributesRoleForToken[tokenIdentifier] ?? 0
            case .modifyRoyalties:
                self.numberOfAccountWithModifyRoyaltiesRoleForToken[tokenIdentifier] ?? 0
            default:
                fatalError("Not implemented.")
            }
            
            result += numberToAdd
        }
        
        return result
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
        tokenIdentifier: Data,
        amount: BigInt,
        hash: Data,
        name: Data,
        attributes: Data,
        creator: Data,
        royalties: BigInt,
        uris: Data
    ) -> UInt64 {
        let newNonce = self.nextNonceForNonFungibleToken[tokenIdentifier] ?? 1
        
        guard let tokenType = self.tokenTypeForToken[tokenIdentifier] else {
            smartContractError(message: "Token not found.") // TODO: use the same token identifier as the WASM VM
        }
        
        let tokenDataKey = TokenIdentifierAndNonce(
            tokenIdentifier: tokenIdentifier,
            nonce: newNonce
        )
        
        let tokenData = WorldState.TokenData(
            tokenType: tokenType,
            amount: amount,
            frozen: false,
            hash: hash,
            name: name,
            attributes: attributes,
            creator: creator,
            royalties: royalties,
            uris: uris
        )
        
        self.nextNonceForNonFungibleToken[tokenIdentifier] = newNonce + 1
        self.tokenDataForToken[tokenDataKey] = tokenData
        
        return newNonce
    }
    
    package mutating func doesNonFungibleNonceExist(
        tokenIdentifier: Data,
        nonce: UInt64
    ) -> Bool {
        nonce < (self.nextNonceForNonFungibleToken[tokenIdentifier] ?? 0)
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
    
    package func getTokenData(
        tokenIdentifier: Data,
        nonce: UInt64
    ) -> TokenData? {
        let key = TokenIdentifierAndNonce(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
        
        return self.tokenDataForToken[key]
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
