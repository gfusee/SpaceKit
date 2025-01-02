import SpaceKit
import SpaceKitTesting
import BigInt

@Controller public struct EgldTransferController {
    
    public func transferEgld(to: Address, value: BigUint) {
        to.send(egldValue: value)
    }
    
    public func transferEgldThenFail(to: Address, value: BigUint) {
        to.send(egldValue: value)
        
        let _ = BigUint(integerLiteral: 0) - BigUint(integerLiteral: 1)
    }
    
    public func transferEsdt(to: Address) {
        to.send(payments: Message.allEsdtTransfers)
    }
    
}

final class TransferAndExecuteTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                balance: 100,
                controllers: [
                    EgldTransferController.self
                ]
            ),
            WorldAccount(
                address: "user",
                balance: 100,
                esdtBalances: [
                    "WEGLD-abcdef": [
                        EsdtBalance(nonce: 0, balance: 1000)
                    ],
                    "SFT-abcdef": [
                        EsdtBalance(nonce: 2, balance: 1000),
                        EsdtBalance(nonce: 10, balance: 1000)
                    ],
                    "OTHER-abcdef": [
                        EsdtBalance(nonce: 3, balance: 1000),
                    ]
                ]
            ),
            WorldAccount(
                address: "user2",
                balance: 100
            ),
        ]
    }
    
    func testSendEgld() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EgldTransferController.self, for: "contract")!
        
        let user = self.getAccount(address: "user")!
        
        let contractBalanceBefore = self.getAccount(address: "contract")!.getBalance()
        let userBalanceBefore = user.getBalance()
        
        XCTAssertEqual(contractBalanceBefore, 100)
        XCTAssertEqual(userBalanceBefore, 100)
        
        try controller.transferEgld(to: user.toAddress(), value: 10)
        
        let userBalanceAfter = self.getAccount(address: "user")!.getBalance()
        let contractBalanceAfter = self.getAccount(address: "contract")!.getBalance()
        
        XCTAssertEqual(userBalanceAfter, 110)
        XCTAssertEqual(contractBalanceAfter, 90)
    }
    
    func testSendAllEgldBalance() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EgldTransferController.self, for: "contract")!
        
        let user = self.getAccount(address: "user")!
        
        try controller.transferEgld(to: user.toAddress(), value: 100)
        
        let userBalance = self.getAccount(address: "user")!.getBalance()
        let contractBalance = self.getAccount(address: "contract")!.getBalance()
        
        XCTAssertEqual(userBalance, 200)
        XCTAssertEqual(contractBalance, 0)
    }
    
    func testSendEgldTransactionFailedShouldRevert() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EgldTransferController.self, for: "contract")!
        
        let user = self.getAccount(address: "user")!
        
        try? controller.transferEgldThenFail(to: user.toAddress(), value: 10)
        
        let userBalance = self.getAccount(address: "user")!.getBalance()
        let contractBalance = self.getAccount(address: "contract")!.getBalance()
        
        XCTAssertEqual(userBalance, 100)
        XCTAssertEqual(contractBalance, 100)
    }
    
    func testSendEgldNotEnoughBalanceShouldRevert() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EgldTransferController.self, for: "contract")!
        
        let user = self.getAccount(address: "user")!
        
        do {
            try controller.transferEgld(to: user.toAddress(), value: 101)
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "insufficient funds"))
        }
        
        let userBalance = self.getAccount(address: "user")!.getBalance()
        let contractBalance = self.getAccount(address: "contract")!.getBalance()
        
        XCTAssertEqual(userBalance, 100)
        XCTAssertEqual(contractBalance, 100)
    }
    
    func testSendMultipleTokens() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EgldTransferController.self, for: "contract")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0,
                amount: 50
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10,
                amount: 150
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3,
                amount: 200
            )
        )
        
        try controller.transferEsdt(
            to: "user2",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtValue
            )
        )
        
        let userWEGLDBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let user2WEGLDBalance = self.getAccount(address: "user2")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        
        let userSFT2Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let user2SFT2Balance = self.getAccount(address: "user2")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        
        let userSFT10Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let user2SFT10Balance = self.getAccount(address: "user2")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        
        let userOtherBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let user2OtherBalance = self.getAccount(address: "user2")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        
        let expectedUserWEGLDBalance: BigUint = 950
        let expectedUser2WEGLDBalance: BigUint = 50
        
        let expectedUserSFT2Balance: BigUint = 900
        let expectedUser2SFT2Balance: BigUint = 100
        
        let expectedUserSFT10Balance: BigUint = 850
        let expectedUser2SFT10Balance: BigUint = 150
        
        let expectedUserOtherBalance: BigUint = 800
        let expectedUser2OtherBalance: BigUint = 200
        
        XCTAssertEqual(userWEGLDBalance, expectedUserWEGLDBalance)
        XCTAssertEqual(user2WEGLDBalance, expectedUser2WEGLDBalance)
        
        XCTAssertEqual(userSFT2Balance, expectedUserSFT2Balance)
        XCTAssertEqual(user2SFT2Balance, expectedUser2SFT2Balance)
        
        XCTAssertEqual(userSFT10Balance, expectedUserSFT10Balance)
        XCTAssertEqual(user2SFT10Balance, expectedUser2SFT10Balance)
        
        XCTAssertEqual(userOtherBalance, expectedUserOtherBalance)
        XCTAssertEqual(user2OtherBalance, expectedUser2OtherBalance)
    }
}
