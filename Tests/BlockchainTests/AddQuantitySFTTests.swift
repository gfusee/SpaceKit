import SpaceKitTesting

final class AddQuantitySFTTests: ContractTestCase {
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
    
    func testAddQuantitySemiFungibleTokens() throws {
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
            roles: EsdtLocalRoles(canAddNftQuantity: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        try controller.mintAndSendTokens(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            amount: 150,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user"
            )
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 1
            )
        
        XCTAssertEqual(userTestBalance, 250)
    }
    
    func testAddQuantitySemiFungibleTokensButWrongNonceShouldFail() throws {
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
            roles: EsdtLocalRoles(canAddNftQuantity: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        do {
            try controller.mintAndSendTokens(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 2,
                amount: 150,
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user"
                )
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token and nonce not found."))
        }
    }

    func testAddQuantitySemiFungibleTokensButDoesntHaveTheRoleShouldFail() throws {
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
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        do {
            try controller.mintAndSendTokens(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                amount: 150,
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user"
                )
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to add quantity."))
        }
    }
    
    func testAddQuantityMetaEsdt() throws {
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
            roles: EsdtLocalRoles(canAddNftQuantity: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        try controller.mintAndSendTokens(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 1,
            amount: 150,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user"
            )
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 1
            )
        
        XCTAssertEqual(userTestBalance, 250)
    }
    
    func testAddQuantityMetaEsdtButDoesntHaveTheRoleShouldFail() throws {
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
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        do {
            try controller.mintAndSendTokens(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                amount: 150,
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user"
                )
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to add quantity."))
        }
    }
}
