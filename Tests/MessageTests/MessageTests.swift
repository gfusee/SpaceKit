import XCTest
import Space

@Contract struct MessageContract {
    
    @Storage(key: "address") var address: Address
    
    init() {
        self.address = Message.caller
    }
    
    public func getCallerAddress() -> Address {
        return Message.caller
    }
    
    public func getStorageAddress() -> Address {
        return self.address
    }

    public func getEgldValue() -> BigUint {
        return Message.egldValue
    }

    public func getAllEsdtTransfers() -> MXArray<TokenPayment> {
        return Message.allEsdtTransfers
    }
}

final class MessageTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "adder"),
            WorldAccount(
                address: "user",
                balance: 1000,
                esdtBalances: [
                    "WEGLD-abcdef": [
                        EsdtBalance(nonce: 0, balance: 1000)
                    ],
                    "SFT-abcdef": [
                        EsdtBalance(nonce: 1, balance: 500),
                        EsdtBalance(nonce: 2, balance: 50)
                    ]
                ]
            )
        ]
    }
    
    func testGetCallerInInitNotSet() throws {
        let contract = try MessageContract.testable("adder")
        
        let storedAddress = try contract.getStorageAddress()
        
        XCTAssertEqual(storedAddress.hexDescription, "0000000000000000000061646465725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCallerInInit() throws {
        let contract = try MessageContract.testable(
            "adder",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        let storedAddress = try contract.getStorageAddress()
        
        XCTAssertEqual(storedAddress.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCallerNotSet() throws {
        let contract = try MessageContract.testable("adder")
        
        let contractAddress = try contract.getCallerAddress()
        
        XCTAssertEqual(contractAddress.hexDescription, "0000000000000000000061646465725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCaller() throws {
        let contract = try MessageContract.testable("adder")
        
        let contractAddress = try contract.getCallerAddress(
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        XCTAssertEqual(contractAddress.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }

    func testGetEgldValueNoValue() throws {
        let contract = try MessageContract.testable("adder")
        
        let value = try contract.getEgldValue()
        
        XCTAssertEqual(value, 0)
    }

    // TODO: add a test that ensures it is impossible to provide both egldValue and esdtValue

    func testGetEgldValue() throws {
        let contract = try MessageContract.testable("adder")
        
        let value = try contract.getEgldValue(transactionInput: ContractCallTransactionInput(callerAddress: "user", egldValue: 100))
        
        XCTAssertEqual(value, 100)
        XCTAssertEqual(self.getAccount(address: "adder")!.balance, 100)
        XCTAssertEqual(self.getAccount(address: "user")!.balance, 900)
    }

    func testGetAllEsdtTransfersNoTransfers() throws {
        let contract = try MessageContract.testable("adder")
        
        let value = try contract.getAllEsdtTransfers()
        
        XCTAssertEqual(value, [])
    }

    func testGetAllEsdtTransfersSingleTransfer() throws {
        let contract = try MessageContract.testable("adder")
        
        let value = try contract.getAllEsdtTransfers(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: [TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100)]
            )
        )
        
        XCTAssertEqual(value, [TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100)])
        XCTAssertEqual(self.getAccount(address: "adder")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 100)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 900)
    }

    func testGetAllEsdtTransfersMultiTransfers() throws {
        let contract = try MessageContract.testable("adder")
        
        let value = try contract.getAllEsdtTransfers(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: [
                    TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100),
                    TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 1, amount: 10),
                    TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 2, amount: 50)
                ]
            )
        )

        let expected: MXArray<TokenPayment> = [
            TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100),
            TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 1, amount: 10),
            TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 2, amount: 50)
        ]
        
        XCTAssertEqual(value, expected)

        XCTAssertEqual(self.getAccount(address: "adder")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 100)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 900)

        XCTAssertEqual(self.getAccount(address: "adder")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 1), 10)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 1), 490)

        XCTAssertEqual(self.getAccount(address: "adder")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 2), 50)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 2), 0)
    }
}
