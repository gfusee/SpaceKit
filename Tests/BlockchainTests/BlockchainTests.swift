import SpaceKitTesting

@Controller public struct BlockchainController {
    
    public func getSelfAddress() -> Address {
        return Blockchain.getSCAddress()
    }
    
    public func getBalance(
        address: Address
    ) -> BigUint {
        return Blockchain.getBalance(address: address)
    }
    
    public func getSCBalance() -> BigUint {
        Blockchain.getSCBalance()
    }
    
    public func getEsdtBalance(
        address: Address,
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        return Blockchain.getESDTBalance(address: address, tokenIdentifier: tokenIdentifier, nonce: nonce)
    }
    
    public func getSCEsdtBalance(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        Blockchain
            .getSCBalance(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce
            )
    }

    public func getOwner() -> Address {
        return Blockchain.getOwner()
    }
    
    public func getShard(address: Address) -> UInt32 {
        address.getShard()
    }
}

final class BlockchainTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                 balance: 1500,
                 esdtBalances: [
                    "SFT-abcdef": [
                        EsdtBalance(nonce: 5, balance: 20)
                    ]
                 ],
                controllers: [
                    BlockchainController.self
                ]
            ),
            WorldAccount(
                address: "user",
                balance: 1000
            ),
            WorldAccount(
                address: "userFungible",
                esdtBalances: [
                    "WEGLD-abcdef": [
                        EsdtBalance(nonce: 0, balance: 50)
                    ]
                ]
            ),
            WorldAccount(
                address: "userNonFungible",
                esdtBalances: [
                    "SFT-abcdef": [
                        EsdtBalance(nonce: 10, balance: 40)
                    ]
                ]
            ),
            WorldAccount(address: "userNoBalance")
        ]
    }
    
    func testGetSCAddress() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let contractAddress = try controller.getSelfAddress()
        
        XCTAssertEqual(contractAddress.hexDescription, "00000000000000000000636f6e74726163745f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetBalanceOnZeroBalanceAccount() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getBalance(address: "userNoBalance")
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetBalanceUnknownAccount() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getBalance(address: "unknown")
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetBalance() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getBalance(address: "user")
        
        XCTAssertEqual(balance, 1000)
    }
    
    func testGetSCBalance() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getSCBalance()
        
        XCTAssertEqual(balance, 1500)
    }

    func testGetEsdtBalanceOnZeroBalanceAccount() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getEsdtBalance(address: "adder", tokenIdentifier: "WEGLD-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtBalanceUnknownAccount() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getEsdtBalance(address: "unknown", tokenIdentifier: "WEGLD-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtBalanceUnknownToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getEsdtBalance(address: "userFungible", tokenIdentifier: "USDC-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtBalanceUnknownNonce() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getEsdtBalance(address: "userFungible", tokenIdentifier: "WEGLD-abcdef", nonce: 1)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtFungibleBalance() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getEsdtBalance(address: "userFungible", tokenIdentifier: "WEGLD-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 50)
    }
    
    func testGetEsdtNonFungibleBalance() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getEsdtBalance(address: "userNonFungible", tokenIdentifier: "SFT-abcdef", nonce: 10)
        
        XCTAssertEqual(balance, 40)
    }
    
    func testGetSCBalanceWithEsdt() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getSCEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 5)
        
        XCTAssertEqual(balance, 20)
    }
    
    func testGetSCBalanceWithUUnknownEsdt() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let balance = try controller.getSCEsdtBalance(tokenIdentifier: "UNKNOWN-abcdef", nonce: 5)
        
        XCTAssertEqual(balance, 0)
    }

    func testGetOwnerDefaultOwner() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let owner = try controller.getOwner()
        
        XCTAssertEqual(owner.hexDescription, "00000000000000000000636f6e74726163745f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }

    func testGetOwner() throws {
        try self.deployContract(
            at: "contract",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let owner = try controller.getOwner()
        
        XCTAssertEqual(owner.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetShardOfAddressOnShard0() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let shard = try controller.getShard(address: Address(buffer: Buffer(data: Array("f82b37a187e2fa215a160149a9200dbb96da44d51b0943fd2fb7c387642f4420".hexadecimal))))
        
        XCTAssertEqual(shard, 0)
    }
    
    func testGetShardOfAddressOnShard1() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let shard = try controller.getShard(address: Address(buffer: Buffer(data: Array("b80df5db4ccedd88c45c42b567a383cc87188aeaa1c75cc8cfab2f500d01fecf".hexadecimal))))
        
        XCTAssertEqual(shard, 1)
    }
    
    func testGetShardOfAddressOnShard2() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let shard = try controller.getShard(address: Address(buffer: Buffer(data: Array("b57d0b1ae1c2141d17bbb4fe1ce680875fb3b318015799536d6f0de6a8d173fe".hexadecimal))))
        
        XCTAssertEqual(shard, 2)
    }
    
    func testGetShardOfAddressOnMetachain() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let shard = try controller.getShard(address: Address(buffer: Buffer(data: Array("000000000000000000010000000000000000000000000000000000000002ffff".hexadecimal))))
        
        XCTAssertEqual(shard, 4294967295)
    }
    
    func testGetShardOfEmptyAddress() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(BlockchainController.self, for: "contract")!
        
        let shard = try controller.getShard(address: Address(buffer: Buffer(data: Array("0000000000000000000000000000000000000000000000000000000000000000".hexadecimal))))
        
        XCTAssertEqual(shard, 4294967295)
    }
    
}
