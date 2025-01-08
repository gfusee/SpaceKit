import SpaceKit
import BigInt
import SpaceKitTesting

@Controller public struct TokenIssuanceController {
    @Storage(key: "lastIssuedTokenIdentifier") var lastIssuedTokenIdentifier: Buffer
    @Storage(key: "lastErrorMessage") var lastErrorMessage: Buffer
    
    public func issueToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        initialSupply: BigUint,
        properties: FungibleTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                initialSupply: initialSupply,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: initialSupply,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    public func issueNonFungible(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        properties: NonFungibleTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueNonFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: 0,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    public func issueSemiFungible(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        properties: SemiFungibleTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueSemiFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: 0,
                    gasForCallback: 100_000_000
                )
            )
    }

    public func createAndSendNonFungibleToken(
        tokenIdentifier: Buffer,
        amount: BigUint,
        to: Address
    ) {
        let createdNonce = Blockchain.createNft(
            tokenIdentifier: tokenIdentifier,
            amount: amount,
            name: "MyNFT",
            royalties: 0,
            hash: "",
            attributes: IgnoreValue(),
            uris: Vector()
        )
        
        to.send(
            tokenIdentifier: tokenIdentifier,
            nonce: createdNonce,
            amount: amount
        )
    }
    
    public func mintAndSendTokens(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        amount: BigUint
    ) {
        Blockchain
            .mintTokens(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                amount: amount
            )
        
        if amount > 0 {
            Message.caller
                .send(
                    tokenIdentifier: tokenIdentifier,
                    nonce: nonce,
                    amount: amount
                )
        }
    }
    
    public func setTokenRoles(
        tokenIdentifier: Buffer,
        address: Address,
        roles: Int32
    ) {
        Blockchain.setTokenRoles(
            for: address,
            tokenIdentifier: tokenIdentifier,
            roles: EsdtLocalRoles(flags: roles)
        )
        .registerPromise(
            gas: 100_000_000,
            callback: self.$setSpecialRolesCallback(gasForCallback: 100_000_000)
        )
    }
    
    public func getLastIssuedTokenIdentifier() -> Buffer {
        self.lastIssuedTokenIdentifier
    }

    public func getLastErrorMessage() -> Buffer {
        self.lastErrorMessage
    }
    
    @Callback public mutating func issueCallback(
        caller: Address,
        mintedAmount: BigUint
    ) {
        let asyncResult: AsyncCallResult<Buffer> = Message.asyncCallResult()
        
        switch asyncResult {
        case .success(let tokenIdentifier):
            self.lastIssuedTokenIdentifier = tokenIdentifier
            
            if mintedAmount > 0 {
                caller.send(
                    tokenIdentifier: tokenIdentifier,
                    nonce: 0,
                    amount: mintedAmount
                )
            }
        case .error(let asyncCallError):
            self.lastErrorMessage = asyncCallError.errorMessage
        }
    }
    
    @Callback public mutating func setSpecialRolesCallback() {
        let asyncResult: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
        
        switch asyncResult {
        case .success(_):
            break
        case .error(let error):
            self.lastErrorMessage = error.errorMessage
        }
    }
}

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
                    TokenIssuanceController.self
                ]
            ),
            WorldAccount(
                address: "contract2",
                controllers: [
                    TokenIssuanceController.self
                ]
            )
        ]
    }
    
    func testIssueFungibleToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
            amount: 100,
            to: "user"
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 1
            )
        
        XCTAssertEqual(userTestBalance, 100)
    }
    
    func testIssueSemiFungibleToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
    
    func testSetSpecialRolesButCannotAddSpecialRoleShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
                amount: 100,
                to: "user"
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "Caller doesn't have the role to create nft."))
        }
    }
    
    func testCreateNonFungibleTokenButTokenIsFungibleShouldFail() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        let controller2 = self.instantiateController(TokenIssuanceController.self, for: "contract2")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
    
    func testAddQuantitySemiFungibleTokens() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
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
        
        try! controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canCreateNft: true).flags
        )
        
        try! controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canAddNftQuantity: true).flags
        )
        
        try! controller.createAndSendNonFungibleToken(
            tokenIdentifier: issuedTokenIdentifier,
            amount: 100,
            to: "user"
        )
        
        try! controller.mintAndSendTokens(
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
                nonce: 0
            )
        
        XCTAssertEqual(userTestBalance, 250)
    }
}
