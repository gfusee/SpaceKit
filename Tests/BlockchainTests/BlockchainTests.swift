import XCTest
import Space

@Contract struct BlockchainContract {
    
    public func getSelfAddress() -> Address {
        return Blockchain.getSCAddress()
    }
    
    public func getBalance(
        address: Address
    ) -> BigUint {
        return Blockchain.getBalance(address: address)
    }
    
    public func getEsdtBalance(
        address: Address,
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        return Blockchain.getESDTBalance(address: address, tokenIdentifier: tokenIdentifier, nonce: nonce)
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
            WorldAccount(address: "adder"),
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
            )
        ]
    }
    
    func testGetSCAddress() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let contractAddress = try contract.getSelfAddress()
        
        XCTAssertEqual(contractAddress.hexDescription, "0000000000000000000061646465725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetBalanceOnZeroBalanceAccount() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getBalance(address: "adder")
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetBalanceUnknownAccount() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getBalance(address: "unknown")
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetBalance() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getBalance(address: "user")
        
        XCTAssertEqual(balance, 1000)
    }
    
    func testGetEsdtBalanceOnZeroBalanceAccount() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getEsdtBalance(address: "adder", tokenIdentifier: "WEGLD-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtBalanceUnknownAccount() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getEsdtBalance(address: "unknown", tokenIdentifier: "WEGLD-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtBalanceUnknownToken() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getEsdtBalance(address: "userFungible", tokenIdentifier: "USDC-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtBalanceUnknownNonce() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getEsdtBalance(address: "userFungible", tokenIdentifier: "WEGLD-abcdef", nonce: 1)
        
        XCTAssertEqual(balance, 0)
    }
    
    func testGetEsdtFungibleBalance() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getEsdtBalance(address: "userFungible", tokenIdentifier: "WEGLD-abcdef", nonce: 0)
        
        XCTAssertEqual(balance, 50)
    }
    
    func testGetEsdtNonFungibleBalance() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let balance = try contract.getEsdtBalance(address: "userNonFungible", tokenIdentifier: "SFT-abcdef", nonce: 10)
        
        XCTAssertEqual(balance, 40)
    }

    func testGetOwnerDefaultOwner() throws {
        let contract = try BlockchainContract.testable("adder")
        
        let owner = try contract.getOwner()
        
        XCTAssertEqual(owner.hexDescription, "0000000000000000000061646465725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }

    func testGetOwner() throws {
        let contract = try BlockchainContract.testable(
            "adder",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        let owner = try contract.getOwner()
        
        XCTAssertEqual(owner.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetShardOfAddressOnShard0() throws {
        let contract = try BlockchainContract.testable(
            "adder",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        let shard = try contract.getShard(address: Address(buffer: Buffer(data: Array("f82b37a187e2fa215a160149a9200dbb96da44d51b0943fd2fb7c387642f4420".hexadecimal))))
        
        XCTAssertEqual(shard, 0)
    }
    
    func testGetShardOfAddressOnShard1() throws {
        let contract = try BlockchainContract.testable(
            "adder",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        let shard = try contract.getShard(address: Address(buffer: Buffer(data: Array("b80df5db4ccedd88c45c42b567a383cc87188aeaa1c75cc8cfab2f500d01fecf".hexadecimal))))
        
        XCTAssertEqual(shard, 1)
    }
    
    func testGetShardOfAddressOnShard2() throws {
        let contract = try BlockchainContract.testable(
            "adder",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        let shard = try contract.getShard(address: Address(buffer: Buffer(data: Array("b57d0b1ae1c2141d17bbb4fe1ce680875fb3b318015799536d6f0de6a8d173fe".hexadecimal))))
        
        XCTAssertEqual(shard, 2)
    }
    
    func testGetShardOfAddressOnMetachain() throws {
        let contract = try BlockchainContract.testable(
            "adder",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        let shard = try contract.getShard(address: Address(buffer: Buffer(data: Array("000000000000000000010000000000000000000000000000000000000002ffff".hexadecimal))))
        
        XCTAssertEqual(shard, 4294967295)
    }
    
    func testGetShardOfEmptyAddress() throws {
        let contract = try BlockchainContract.testable(
            "adder",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        let shard = try contract.getShard(address: Address(buffer: Buffer(data: Array("0000000000000000000000000000000000000000000000000000000000000000".hexadecimal))))
        
        XCTAssertEqual(shard, 4294967295)
    }
    
}
