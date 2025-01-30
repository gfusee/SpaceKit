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
    
    func testIssueFungibleTokenButDisplayNameTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "Te",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testIssueFungibleTokenButDisplayNameTooLongShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testIssueFungibleTokenButTickerTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "TE",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testIssueFungibleTokenButTickerTooLongFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "AAAAAAAAAAA",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testIssueFungibleTokenButTickerContainsLowercaseShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "TeST",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testIssueFungibleTokenButNumberOfDecimalsTooHighFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            initialSupply: 100,
            properties: FungibleTokenProperties(
                numDecimals: 19,
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "num decimals too high.")
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
            royalties: 0,
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
    
    func testIssueNonFungibleTokenButDisplayNameTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "Te",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testIssueNonFungibleTokenButDisplayNameTooLongShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testIssueNonFungibleTokenButTickerTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TE",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testIssueNonFungibleTokenButTickerTooLongFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "AAAAAAAAAAA",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testIssueNonFungibleTokenButTickerContainsLowercaseShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueNonFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TeST",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
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
            royalties: 0,
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
    
    func testIssueSemiFungibleTokenButDisplayNameTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueSemiFungible(
            tokenDisplayName: "Te",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testIssueSemiFungibleTokenButDisplayNameTooLongShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueSemiFungible(
            tokenDisplayName: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testIssueSemiFungibleTokenButTickerTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueSemiFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TE",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testIssueSemiFungibleTokenButTickerTooLongFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueSemiFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "AAAAAAAAAAA",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testIssueSemiFungibleTokenButTickerContainsLowercaseShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.issueSemiFungible(
            tokenDisplayName: "TestToken",
            tokenTicker: "TeST",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
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
            royalties: 0,
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
    
    func testRegisterMetaEsdtButDisplayNameTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerMetaEsdt(
            tokenDisplayName: "Te",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testRegisterMetaEsdtButDisplayNameTooLongShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerMetaEsdt(
            tokenDisplayName: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token display name.")
    }
    
    func testRegisterMetaEsdtButTickerTooShortShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerMetaEsdt(
            tokenDisplayName: "TestToken",
            tokenTicker: "TE",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testRegisterMetaEsdtButTickerTooLongFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerMetaEsdt(
            tokenDisplayName: "TestToken",
            tokenTicker: "AAAAAAAAAAA",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testRegisterMetaEsdtButTickerContainsLowercaseShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerMetaEsdt(
            tokenDisplayName: "TestToken",
            tokenTicker: "TeST",
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "invalid token ticker.")
    }
    
    func testRegisterMetaEsdtButNumberOfDecimalsTooHighFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerMetaEsdt(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            properties: MetaTokenProperties(
                numDecimals: 19,
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
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "num decimals too high.")
    }
    
    func testRegisterAndSetAllRolesForFungibleToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerAndSetAllRoles(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            tokenType: .fungible,
            numDecimals: 18,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        let roleFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let roles = EsdtLocalRoles(flags: roleFlags)
        
        let expected = EsdtLocalRoles(
            canMint: true,
            canBurn: true,
            canCreateNft: true,
            canAddNftQuantity: true,
            canBurnNft: true,
            canUpdateNftAttributes: true,
            canAddNftUri: true,
            canRecreateNft: true,
            canModifyCreator: true,
            canModifyRoyalties: true,
            canSetNewUri: true
        )
        
        XCTAssertEqual(roles, expected)
    }

    func testRegisterAndSetAllRolesForNonFungibleToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerAndSetAllRoles(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            tokenType: .nonFungible,
            numDecimals: 0,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        let roleFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let roles = EsdtLocalRoles(flags: roleFlags)
        
        let expected = EsdtLocalRoles(
            canMint: true,
            canBurn: true,
            canCreateNft: true,
            canAddNftQuantity: true,
            canBurnNft: true,
            canUpdateNftAttributes: true,
            canAddNftUri: true,
            canRecreateNft: true,
            canModifyCreator: true,
            canModifyRoyalties: true,
            canSetNewUri: true
        )
        
        XCTAssertEqual(roles, expected)
    }

    func testRegisterAndSetAllRolesForSemiFungibleToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerAndSetAllRoles(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            tokenType: .semiFungible,
            numDecimals: 18,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        let roleFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let roles = EsdtLocalRoles(flags: roleFlags)
        
        let expected = EsdtLocalRoles(
            canMint: true,
            canBurn: true,
            canCreateNft: true,
            canAddNftQuantity: true,
            canBurnNft: true,
            canUpdateNftAttributes: true,
            canAddNftUri: true,
            canRecreateNft: true,
            canModifyCreator: true,
            canModifyRoyalties: true,
            canSetNewUri: true
        )
        
        XCTAssertEqual(roles, expected)
    }

    func testRegisterAndSetAllRolesForMetaToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        try controller.registerAndSetAllRoles(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            tokenType: .meta,
            numDecimals: 18,
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                egldValue: BigUint(bigInt: self.issuanceCost)
            )
        )
        
        let issuedTokenIdentifier = try controller.getLastIssuedTokenIdentifier()
        let roleFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let roles = EsdtLocalRoles(flags: roleFlags)
        
        let expected = EsdtLocalRoles(
            canMint: true,
            canBurn: true,
            canCreateNft: true,
            canAddNftQuantity: true,
            canBurnNft: true,
            canUpdateNftAttributes: true,
            canAddNftUri: true,
            canRecreateNft: true,
            canModifyCreator: true,
            canModifyRoyalties: true,
            canSetNewUri: true
        )
        
        XCTAssertEqual(roles, expected)
    }

    func testRegisterAndSetAllRolesForInvalidTokenShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenTestsController.self, for: "contract")!
        
        
        do {
            try controller.registerAndSetAllRoles(
                tokenDisplayName: "TestToken",
                tokenTicker: "TEST",
                tokenType: .invalid,
                numDecimals: 0,
                transactionInput: ContractCallTransactionInput(
                    callerAddress: "user",
                    egldValue: BigUint(bigInt: self.issuanceCost)
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Invalid token type."))
        }
    }
}
