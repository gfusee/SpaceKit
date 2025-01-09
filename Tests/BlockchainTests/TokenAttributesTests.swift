import SpaceKit
import BigInt
import SpaceKitTesting

final class TokenAttributesTests: ContractTestCase {
    private let issuanceCost: BigInt = 5 * (BigInt(10).power(16))
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "user",
                balance: 100 * self.issuanceCost
            ),
            WorldAccount(
                address: "contract",
                controllers: [
                    TokenTestsController.self
                ]
            ),
            WorldAccount(
                address: "contract2",
                controllers: [
                    TokenTestsController.self
                ]
            )
        ]
    }
    
    func testCreateWithAttributesEmpty() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: NonFungibleTokenProperties(
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canTransferCreateRole: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true).flags
        )
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canAddNftQuantity: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            attributes: Buffer(),
            to: "user"
        )
        
        let attributes = self.getTokenAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(attributes, "")
    }
    
    func testCreateWithAttributesNonEmpty() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: NonFungibleTokenProperties(
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canTransferCreateRole: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            attributes: "Hello World!",
            to: "user"
        )
        
        let attributes = self.getTokenAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(attributes, "Hello World!")
    }
    
    func testUpdateAttributesEmpty() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: NonFungibleTokenProperties(
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canTransferCreateRole: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true, canUpdateNftAttributes: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            attributes: "Hello World!",
            to: "user"
        )
        
        try controller.updateAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: Buffer()
        )
        
        let attributes = self.getTokenAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(attributes, "")
    }
    
    func testUpdateAttributesNonEmpty() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: NonFungibleTokenProperties(
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canTransferCreateRole: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true, canUpdateNftAttributes: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            attributes: "Hello World!",
            to: "user"
        )
        
        try controller.updateAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: "New attributes!"
        )
        
        let attributes = self.getTokenAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(attributes, "New attributes!")
    }
    
    func testUpdateAttributesButTokenIsFungibleShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            initialSupply: 100,
            properties: FungibleTokenProperties(
                numDecimals: 18,
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canMint: false,
                canBurn: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )
        
        do {
            try controller.updateAttributes(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                attributes: "New attributes!"
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not a non fungible token."))
        }
    }
    
    func testUpdateAttributesButWrongNonceShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: NonFungibleTokenProperties(
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canTransferCreateRole: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true, canUpdateNftAttributes: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            attributes: "Hello World!",
            to: "user"
        )
        
        do {
            try controller.updateAttributes(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 2,
                attributes: "New attributes!"
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token and nonce not found."))
        }
    }

    func testUpdateAttributesButDoesntHaveRoleShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: NonFungibleTokenProperties(
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canTransferCreateRole: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            attributes: "Hello World!",
            to: "user"
        )
        
        do {
            try controller.updateAttributes(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                attributes: "New attributes!"
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to update attributes."))
        }
    }
}
