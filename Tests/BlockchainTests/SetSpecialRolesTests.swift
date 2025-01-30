import SpaceKitTesting

final class SetSpecialRolesTests: ContractTestCase {
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
    
    func testSetSpecialRolesCanMint() throws {
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
            roles: EsdtLocalRoles(canMint: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canMint: true)
        XCTAssertEqual(contractRoles, expected)
    }
    
    func testSetSpecialRolesCanBurn() throws {
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
            roles: EsdtLocalRoles(canBurn: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canBurn: true)
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesCanCreateNft() throws {
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

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canCreateNft: true)
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesCanBurnNft() throws {
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
            roles: EsdtLocalRoles(canBurnNft: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canBurnNft: true)
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesCanUpdateNftAttributes() throws {
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
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canUpdateNftAttributes: true)
        XCTAssertEqual(contractRoles, expected)
    }
    
    func testSetSpecialRolesCanUpdateNftAttributesTwiceSameAccount() throws {
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
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canUpdateNftAttributes: true)
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesCanUpdateNftAttributesButTwoAccountsShouldFail() throws {
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
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "user",
            roles: EsdtLocalRoles(canUpdateNftAttributes: true).flags
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Only one account at a time can have the role ESDTRoleNFTUpdateAttributes for a given token.")
    }
    
    func testSetSpecialRolesCanAddNftUri() throws {
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
            roles: EsdtLocalRoles(canAddNftUri: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canAddNftUri: true)
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesCanRecreate() throws {
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
            roles: EsdtLocalRoles(canRecreateNft: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canRecreateNft: true)
        XCTAssertEqual(contractRoles, expected)
    }
    
    func testSetSpecialRolesCanModifyCreator() throws {
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
            roles: EsdtLocalRoles(canModifyCreator: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canModifyCreator: true)
        XCTAssertEqual(contractRoles, expected)
    }
    
    func testSetSpecialRolesCanModifyRoyalties() throws {
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
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canModifyRoyalties: true)
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesCanSetNewUri() throws {
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
            roles: EsdtLocalRoles(canSetNewUri: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canSetNewUri: true)
        XCTAssertEqual(contractRoles, expected)
    }
    
    func testSetSpecialRolesCanModifyRoyaltiesTwiceSameAccount() throws {
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
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(canModifyRoyalties: true)
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesCanModifyRoyaltiesButTwoAccountsShouldFail() throws {
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
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )
        
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "user",
            roles: EsdtLocalRoles(canModifyRoyalties: true).flags
        )
        
        let lastErrorMessage = try controller.getLastErrorMessage()
        
        XCTAssertEqual(lastErrorMessage, "Only one account at a time can have the role ESDTRoleModifyRoyalties for a given token.")
    }

    func testSetSpecialRolesCanMintCanBurnCanRecreateNft() throws {
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
            roles: EsdtLocalRoles(
                canMint: true,
                canBurn: true,
                canRecreateNft: true
            ).flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles(
            canMint: true,
            canBurn: true,
            canRecreateNft: true
        )
        XCTAssertEqual(contractRoles, expected)
    }

    func testSetSpecialRolesNoRolesAdded() throws {
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

        // No roles are added here
        try controller.setTokenRoles(
            tokenIdentifier: issuedTokenIdentifier,
            address: "contract",
            roles: EsdtLocalRoles().flags
        )

        let contractRolesFlags = try controller.getSelfTokenRoles(tokenIdentifier: issuedTokenIdentifier)
        let contractRoles = EsdtLocalRoles(flags: contractRolesFlags)

        let expected = EsdtLocalRoles() // No roles expected
        XCTAssertEqual(contractRoles, expected)
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
}
