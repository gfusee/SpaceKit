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
        
        try! controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        let attributes: Buffer = self.getTokenAttributes(
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
            royalties: 0,
            attributes: "Hello World!",
            to: "user"
        )
        
        let attributes: Buffer = self.getTokenAttributes(
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
            royalties: 0,
            attributes: "Hello World!",
            to: "user"
        )
        
        try controller.updateAttributesRaw(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: Buffer()
        )
        
        let attributes: Buffer = self.getTokenAttributes(
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
            royalties: 0,
            attributes: "Hello World!",
            to: "user"
        )
        
        try controller.updateAttributesRaw(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: "New attributes!"
        )
        
        let attributes: Buffer = self.getTokenAttributes(
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
            try controller.updateAttributesRaw(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                attributes: "New attributes!"
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not a non fungible token."))
        }
    }
    
    func testUpdateAttributesButTokenIsSemiFungibleShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueSemiFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: SemiFungibleTokenProperties(
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
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )
        
        do {
            try controller.updateAttributesRaw(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                attributes: "New attributes!"
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not a non fungible token."))
        }
    }
    
    func testUpdateAttributesButTokenIsMetaShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerMetaEsdt(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: MetaTokenProperties(
                numDecimals: 18,
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
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )
        
        do {
            try controller.updateAttributesRaw(
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
            royalties: 0,
            attributes: "Hello World!",
            to: "user"
        )
        
        do {
            try controller.updateAttributesRaw(
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
            royalties: 0,
            attributes: "Hello World!",
            to: "user"
        )
        
        do {
            try controller.updateAttributesRaw(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                attributes: "New attributes!"
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to update attributes."))
        }
    }
    
    func testUpdateAttributesTyped() throws {
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
            royalties: 0,
            attributes: "Hello World!",
            to: "user"
        )
        
        let attributes = TestAttributes(
            buffer: "Hey!",
            biguint: 150
        )
        
        try controller.updateAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: attributes
        )
        
        let storedAttributes: TestAttributes = self.getTokenAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(storedAttributes, attributes)
    }
    
    func testRetrieveAttributesEmpty() throws {
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
            royalties: 0,
            attributes: "Hello World!",
            to: "contract"
        )
        
        try controller.updateAttributesRaw(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: Buffer()
        )
        
        let storedAttributes = try controller.retrieveAttributesRaw(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(storedAttributes, Buffer())
    }
    
    func testRetrieveAttributesNoUpdate() throws {
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
            royalties: 0,
            attributes: "Hello!",
            to: "contract"
        )
        
        let storedAttributes = try controller.retrieveAttributesRaw(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(storedAttributes, "Hello!")
    }

    func testRetrieveAttributesNonEmpty() throws {
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
            royalties: 0,
            attributes: "Hello World!",
            to: "contract"
        )
        
        try controller.updateAttributesRaw(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: "Hey!"
        )
        
        let storedAttributes = try controller.retrieveAttributesRaw(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(storedAttributes, "Hey!")
    }

    func testRetrieveAttributesTyped() throws {
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
            royalties: 0,
            attributes: "Hello World!",
            to: "contract"
        )
        
        let attributes = TestAttributes(
            buffer: "Hey!",
            biguint: 150
        )
        
        try controller.updateAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            attributes: attributes
        )
        
        let storedAttributes: TestAttributes = try controller.retrieveAttributes(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(storedAttributes, attributes)
    }
    
    func testRetrieveAttributesButDoesntHaveRoleShouldFail() throws {
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
            royalties: 0,
            attributes: "Hello World!",
            to: "user"
        )
        
        do {
            _ = try controller.retrieveAttributes(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token not found for account."))
        }
    }
}
