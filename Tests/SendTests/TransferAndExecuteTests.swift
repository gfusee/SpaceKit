import SpaceKit
import XCTest
import BigInt

@Contract struct EgldTransferContract {
    
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
                balance: 100
            ),
            WorldAccount(
                address: "user",
                balance: 100
            )
        ]
    }
    
    func testSendEgld() throws {
        let contract = try EgldTransferContract.testable("contract")
        let user = self.getAccount(address: "user")!
        
        let contractBalanceBefore = self.getAccount(address: "contract")!.getBalance()
        let userBalanceBefore = user.getBalance()
        
        XCTAssertEqual(contractBalanceBefore, 100)
        XCTAssertEqual(userBalanceBefore, 100)
        
        try contract.transferEgld(to: user.toAddress(), value: 10)
        
        let userBalanceAfter = self.getAccount(address: "user")!.getBalance()
        let contractBalanceAfter = self.getAccount(address: "contract")!.getBalance()
        
        XCTAssertEqual(userBalanceAfter, 110)
        XCTAssertEqual(contractBalanceAfter, 90)
    }
    
    func testSendAllEgldBalance() throws {
        let contract = try EgldTransferContract.testable("contract")
        let user = self.getAccount(address: "user")!
        
        try contract.transferEgld(to: user.toAddress(), value: 100)
        
        let userBalance = self.getAccount(address: "user")!.getBalance()
        let contractBalance = self.getAccount(address: "contract")!.getBalance()
        
        XCTAssertEqual(userBalance, 200)
        XCTAssertEqual(contractBalance, 0)
    }
    
    func testSendEgldTransactionFailedShouldRevert() throws {
        let contract = try EgldTransferContract.testable("contract")
        let user = self.getAccount(address: "user")!
        
        try? contract.transferEgldThenFail(to: user.toAddress(), value: 10)
        
        let userBalance = self.getAccount(address: "user")!.getBalance()
        let contractBalance = self.getAccount(address: "contract")!.getBalance()
        
        XCTAssertEqual(userBalance, 100)
        XCTAssertEqual(contractBalance, 100)
    }
    
    func testSendEgldNotEnoughBalanceShouldRevert() throws {
        let contract = try EgldTransferContract.testable("contract")
        let user = self.getAccount(address: "user")!
        
        do {
            try contract.transferEgld(to: user.toAddress(), value: 101)
            
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
