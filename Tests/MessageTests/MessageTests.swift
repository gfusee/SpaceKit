import XCTest
import SpaceKit

@Init func initialize() {
    var controller = MessageController()
    
    controller.address = Message.caller
}

@Controller struct MessageController {
    @Storage(key: "address") var address: Address
    
    public func getCallerAddress() -> Address {
        return Message.caller
    }
    
    public func getStorageAddress() -> Address {
        return self.address
    }

    public func getEgldValue() -> BigUint {
        return Message.egldValue
    }

    public func getAllEsdtTransfers() -> Vector<TokenPayment> {
        return Message.allEsdtTransfers
    }
}

final class MessageTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    MessageController.self
                ]
            ),
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
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let storedAddress = try controller.getStorageAddress()
        
        XCTAssertEqual(storedAddress.hexDescription, "00000000000000000000636f6e74726163745f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCallerInInit() throws {
        try self.deployContract(
            at: "contract",
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let storedAddress = try controller.getStorageAddress()
        
        XCTAssertEqual(storedAddress.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCallerNotSet() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let contractAddress = try controller.getCallerAddress()
        
        XCTAssertEqual(contractAddress.hexDescription, "00000000000000000000636f6e74726163745f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
    func testGetCaller() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let contractAddress = try controller.getCallerAddress(
            transactionInput: ContractCallTransactionInput(callerAddress: "user")
        )
        
        XCTAssertEqual(contractAddress.hexDescription, "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }

    func testGetEgldValueNoValue() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let value = try controller.getEgldValue()
        
        XCTAssertEqual(value, 0)
    }

    // TODO: add a test that ensures it is impossible to provide both egldValue and esdtValue

    func testGetEgldValue() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let value = try controller.getEgldValue(transactionInput: ContractCallTransactionInput(callerAddress: "user", egldValue: 100))
        
        XCTAssertEqual(value, 100)
        XCTAssertEqual(self.getAccount(address: "contract")!.balance, 100)
        XCTAssertEqual(self.getAccount(address: "user")!.balance, 900)
    }

    func testGetAllEsdtTransfersNoTransfers() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let value = try controller.getAllEsdtTransfers()
        
        XCTAssertEqual(value, [])
    }

    func testGetAllEsdtTransfersSingleTransfer() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let value = try controller.getAllEsdtTransfers(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: [TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100)]
            )
        )
        
        XCTAssertEqual(value, [TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100)])
        XCTAssertEqual(self.getAccount(address: "contract")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 100)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 900)
    }

    func testGetAllEsdtTransfersMultiTransfers() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MessageController.self, for: "contract")!
        
        let value = try controller.getAllEsdtTransfers(
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: [
                    TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100),
                    TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 1, amount: 10),
                    TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 2, amount: 50)
                ]
            )
        )

        let expected: Vector<TokenPayment> = [
            TokenPayment.new(tokenIdentifier: "WEGLD-abcdef", nonce: 0, amount: 100),
            TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 1, amount: 10),
            TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 2, amount: 50)
        ]
        
        XCTAssertEqual(value, expected)

        XCTAssertEqual(self.getAccount(address: "contract")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 100)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "WEGLD-abcdef", nonce: 0), 900)

        XCTAssertEqual(self.getAccount(address: "contract")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 1), 10)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 1), 490)

        XCTAssertEqual(self.getAccount(address: "contract")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 2), 50)
        XCTAssertEqual(self.getAccount(address: "user")!.getEsdtBalance(tokenIdentifier: "SFT-abcdef", nonce: 2), 0)
    }
}
