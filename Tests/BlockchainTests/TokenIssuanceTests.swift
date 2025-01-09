import SpaceKit
import BigInt
import SpaceKitTesting

final class TokenIssuanceTests: ContractTestCase {
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
    
    func testIssueFungibleToken() throws {
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
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        XCTAssertEqual(userTestBalance, 100)
    }
    
    func testIssueMultipleFungibleToken() throws {
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
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            initialSupply: 1000,
            properties: FungibleTokenProperties(
                numDecimals: 18,
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canMint: false,
                canBurn: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "OTHER",
            initialSupply: 10000,
            properties: FungibleTokenProperties(
                numDecimals: 18,
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canMint: false,
                canBurn: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let userTest0Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        let userTest1Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000001",
                nonce: 0
            )
        
        let userOtherBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-000000",
                nonce: 0
            )
        
        XCTAssertEqual(userTest0Balance, 100)
        XCTAssertEqual(userTest1Balance, 1000)
        XCTAssertEqual(userOtherBalance, 10000)
    }

    func testIssueFungibleTokenButNoPaymentShouldFail() throws {
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
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user"
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }
    
    func testIssueFungibleTokenButNotEnoughPaymentShouldFail() throws {
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
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: 100
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }
    
    func testIssueNonFungibleToken() throws {
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
            attributes: Buffer(),
            to: "user"
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 1
            )
        
        XCTAssertEqual(userTestBalance, 1)
    }
    
    func testIssueNonFungibleTokenButNoPaymentShouldFail() throws {
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
                callerAddress: "user"
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }
    
    func testIssueNonFungibleTokenButNotEnoughPaymentShouldFail() throws {
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
                egldValue: 100
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }

    func testCreateNonFungibleTokenButQuantityMoreThanOneShouldFail() throws {
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
        
        do {
            try controller.createAndSendNonFungibleToken(
                tokenIdentifier: issuedTokenIdentifier,
                amount: 100,
                attributes: Buffer(),
                to: "user"
            )

            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "NFT tokens can only have have a supply of 1."))
        }
    }

    func testIssueSemiFungibleToken() throws {
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
            attributes: Buffer(),
            to: "user"
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 1
            )
        
        XCTAssertEqual(userTestBalance, 100)
    }
    
    func testIssueSemiFungibleTokenButNoPaymentShouldFail() throws {
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
                callerAddress: "user"
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }
    
    func testIssueSemiFungibleTokenButNotEnoughPaymentShouldFail() throws {
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
                egldValue: 100
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }
    
    func testRegisterMetaEsdt() throws {
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
            attributes: Buffer(),
            to: "user"
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 1
            )
        
        XCTAssertEqual(userTestBalance, 100)
    }
    
    func testRegisterMetaEsdtButNoPaymentShouldFail() throws {
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
                callerAddress: "user"
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }
    
    func testRegisterMetaEsdtButNotEnoughPaymentShouldFail() throws {
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
                egldValue: 100
            )
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Not enough payment.")
    }

    func testSetSpecialRolesButCannotAddSpecialRoleShouldFail() throws {
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
                canAddSpecialRoles: false
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Cannot add special roles on this token.")
    }
    
    func testCreateNonFungibleTokenButDoesntHaveTheCreateRoleShouldFail() throws {
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
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        do {
            try controller.createAndSendNonFungibleToken(
                tokenIdentifier: issuedTokenIdentifier,
                amount: 1,
                attributes: Buffer(),
                to: "user"
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to create nft."))
        }
    }
    
    func testCreateNonFungibleTokenButTokenIsFungibleShouldFail() throws {
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
                canAddSpecialRoles: false
            ),
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        
        do {
            try controller.createAndSendNonFungibleToken(
                tokenIdentifier: issuedTokenIdentifier,
                amount: 100,
                attributes: Buffer(),
                to: "user"
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not a non fungible token."))
        }
    }

    func testSetSpecialRolesButNotManagerShouldFail() throws {
        try self.deployContract(at: "contract")
        try self.deployContract(at: "contract2")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        let controller2 = self.instantiateController(TokenTestsController.self, for: "contract2")!
        
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
        
        try controller2.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true).flags
        )
        
        let lastErrorMessage = try controller2.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Only the manager of the token can add special roles.")
    }
    
    func testFungibleMintTokens() throws {
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
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        XCTAssertEqual(userTestBalance, 250)
    }
    
    func testMintFungibleTokensButNotMintableShouldFail() throws {
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
            roles: EsdtLocalRoles(canMint: true).flags
        )
        
        do {
            try controller.mintAndSendTokens(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                amount: 150,
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user"
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Token is not mintable."))
        }
    }
    
    func testMintFungibleTokensButDoesntHaveMintRoleShouldFail() throws {
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
        
        do {
            try controller.mintAndSendTokens(
                tokenIdentifier: issuedTokenIdentifier,
                nonce: 0,
                amount: 150,
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user"
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to mint."))
        }
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
