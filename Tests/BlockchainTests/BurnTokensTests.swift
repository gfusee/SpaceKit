import SpaceKitTesting

final class BurnTokensTests: ContractTestCase {
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

    func testFungibleBurnTokens() throws {
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
                canMint: true,
                canBurn: true,
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
            roles: EsdtLocalRoles(canMint: true, canBurn: true).flags
        )
        
        try controller.mintAndSendTokens(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 0,
            amount: 150,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user"
            )
        )
        
        var esdtPayments = Vector<TokenPayment>()
        
        esdtPayments = esdtPayments.appended(
            TokenPayment(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                amount: 250
            )
        )
        
        try controller.burnTokens(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtPayments
            )
        )
        
        let contractTestBalance = self.getAccount(address: "contract")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        XCTAssertEqual(contractTestBalance, 0)
        XCTAssertEqual(userTestBalance, 0)
    }
    
    func testFungibleBurnTokensButTokenNotBurnableShouldFail() throws {
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
                canMint: true,
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
            roles: EsdtLocalRoles(canMint: true, canBurn: true).flags
        )
        
        try controller.mintAndSendTokens(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 0,
            amount: 150,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user"
            )
        )
        
        var esdtPayments = Vector<TokenPayment>()
        
        esdtPayments = esdtPayments.appended(
            TokenPayment(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                amount: 250
            )
        )
        
        do {
            try controller.burnTokens(
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user",
                    esdtValue: esdtPayments
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not burnable."))
        }
    }
    
    func testFungibleBurnTokensButDoesnHaveTheBurnRoleShouldFail() throws {
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
                canMint: true,
                canBurn: true,
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
            roles: EsdtLocalRoles(canMint: true).flags
        )
        
        try controller.mintAndSendTokens(
            tokenIdentifier: issuedTokenIdentifier,
            nonce: 0,
            amount: 150,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user"
            )
        )
        
        var esdtPayments = Vector<TokenPayment>()
        
        esdtPayments = esdtPayments.appended(
            TokenPayment(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                amount: 250
            )
        )
        
        do {
            try controller.burnTokens(
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user",
                    esdtValue: esdtPayments
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to burn."))
        }
    }

    func testNonFungibleBurnTokens() throws {
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
            roles: EsdtLocalRoles(canCreateNft: true, canBurnNft: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 1,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        var esdtPayments = Vector<TokenPayment>()
        
        esdtPayments = esdtPayments.appended(
            TokenPayment(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                amount: 1
            )
        )
        
        try controller.burnTokens(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtPayments
            )
        )
        
        let contractTestBalance = self.getAccount(address: "contract")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        XCTAssertEqual(contractTestBalance, 0)
        XCTAssertEqual(userTestBalance, 0)
    }
    
    func testNonFungibleBurnTokensButDoesnHaveTheBurnRoleShouldFail() throws {
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
            attributes: Buffer(),
            to: "user"
        )
        
        var esdtPayments = Vector<TokenPayment>()
        
        esdtPayments = esdtPayments.appended(
            TokenPayment(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                amount: 1
            )
        )
        
        do {
            try controller.burnTokens(
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user",
                    esdtValue: esdtPayments
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to burn."))
        }
    }
    
    func testSemiFungibleBurnTokens() throws {
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
            roles: EsdtLocalRoles(canCreateNft: true, canBurnNft: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        var esdtPayments = Vector<TokenPayment>()
        
        esdtPayments = esdtPayments.appended(
            TokenPayment(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                amount: 100
            )
        )
        
        try controller.burnTokens(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtPayments
            )
        )
        
        let contractTestBalance = self.getAccount(address: "contract")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        XCTAssertEqual(contractTestBalance, 0)
        XCTAssertEqual(userTestBalance, 0)
    }
    
    func testMetaBurnTokens() throws {
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
            roles: EsdtLocalRoles(canCreateNft: true, canBurnNft: true).flags
        )
        
        try controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            royalties: 0,
            attributes: Buffer(),
            to: "user"
        )
        
        var esdtPayments = Vector<TokenPayment>()
        
        esdtPayments = esdtPayments.appended(
            TokenPayment(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 1,
                amount: 100
            )
        )
        
        try controller.burnTokens(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtPayments
            )
        )
        
        let contractTestBalance = self.getAccount(address: "contract")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        XCTAssertEqual(contractTestBalance, 0)
        XCTAssertEqual(userTestBalance, 0)
    }
}
