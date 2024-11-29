import SpaceKit
import XCTest

@Contract
struct CounterContract {
    @Storage(key: "globalCounter") var globalCounter: BigUint
    
    public mutating func increaseByOne() {
        self.globalCounter += 1
    }
    
    public mutating func increaseByOneThrowError() {
        self.globalCounter += 1
        
        smartContractError(message: "This is an user error.")
    }
    
    public func getGlobalCounterValue() -> Buffer {
        "The global counter is: \(self.globalCounter)"
    }
}

final class ContractStorageTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "counter"),
            WorldAccount(address: "counter1"),
            WorldAccount(address: "counter2")
        ]
    }
    
    func testGetCounterBeforeAnyIncrease() throws {
        let contract = try CounterContract.testable("counter")
        
        let globalCounterValue = try contract.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 0")
    }
    
    func testIncreaseCounterOnce() throws {
        var contract = try CounterContract.testable("counter")
        
        try contract.increaseByOne()
        
        let globalCounterValue = try contract.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 1")
    }
    
    func testIncreaseCounterTwice() throws {
        var contract = try CounterContract.testable("counter")
        
        try contract.increaseByOne()
        try contract.increaseByOne()
        
        let globalCounterValue = try contract.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 2")
    }
    
    func testIncreaseCounterTwoContracts() throws {
        var contract1 = try CounterContract.testable("counter1")
        try contract1.increaseByOne()
        
        var contract2 = try CounterContract.testable("counter2")
        try contract2.increaseByOne()
        try contract2.increaseByOne()
        
        let contract1GlobalCounterValue = try contract1.getGlobalCounterValue()
        let contract2GlobalCounterValue = try contract2.getGlobalCounterValue()
        
        XCTAssertEqual(contract1GlobalCounterValue, "The global counter is: 1")
        XCTAssertEqual(contract2GlobalCounterValue, "The global counter is: 2")
    }
    
    func testIncreaseCounterErrorInTransactionShouldRevert() throws {
        var contract = try CounterContract.testable("counter")
        
        try? contract.increaseByOneThrowError()
        
        let globalCounterValue = try contract.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 0")
    }
    
}
