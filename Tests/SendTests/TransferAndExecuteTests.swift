import SpaceKit
import XCTest
import BigInt

@Controller struct EgldTransferController {
    
    public func transferEgld(to: Address, value: BigUint) {
        to.send(egldValue: value)
    }
    
    public func transferEgldThenFail(to: Address, value: BigUint) {
        to.send(egldValue: value)
        
        let _ = BigUint(integerLiteral: 0) - BigUint(integerLiteral: 1)
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
                balance: 100
            )
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
}
