import SpaceKitTesting

final class TokenRoyaltiesTests: ContractTestCase {
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
    
    func testCreateWithZeroRoyalties() throws {
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
            royalties: 0,
            attributes: Buffer(),
            to: "contract"
        )
        
        let royalties = try controller.retrieveRoyalties(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(royalties, 0)
    }

    func testCreateWithNonZeroRoyalties() throws {
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
            royalties: 10,
            attributes: Buffer(),
            to: "contract"
        )
        
        let royalties = try controller.retrieveRoyalties(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(royalties, 10)
    }
    
    func testRetrieveButDoesntHaveTokenShouldFail() throws {
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
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        do {
            _ = try controller.retrieveRoyalties(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token not found for account."))
        }
    }

    func testModifyRoyalties() throws {
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
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )
        
        try! controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            royalties: 10,
            attributes: Buffer(),
            to: "contract"
        )
        
        try! controller.modifyRoyalties(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            royalties: 100
        )
        
        let royalties = try controller.retrieveRoyalties(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1
        )
        
        XCTAssertEqual(royalties, 100)
    }
    
    func testModifyRoyaltiesButTokenIsSemiFungibleShouldFail() throws {
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
            roles: EsdtLocalRoles(canCreateNft: true).flags
        )
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )
        
        try! controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            royalties: 10,
            attributes: Buffer(),
            to: "contract"
        )
        
        do {
            try controller.modifyRoyalties(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                royalties: 100
            )
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not a non fungible token."))
        }
    }
    
    func testModifyRoyaltiesButTokenIsMetaShouldFail() throws {
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
            roles: EsdtLocalRoles(canCreateNft: true).flags
        )
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )
        
        try! controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            royalties: 10,
            attributes: Buffer(),
            to: "contract"
        )
        
        do {
            try controller.modifyRoyalties(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                royalties: 100
            )
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not a non fungible token."))
        }
    }

    func testModifyRoyaltiesButDoesntHaveRoleShouldFail() throws {
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
        
        try! controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            royalties: 10,
            attributes: Buffer(),
            to: "user"
        )
        
        do {
            try controller.modifyRoyalties(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                royalties: 100
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to modify royalties."))
        }
    }
}
