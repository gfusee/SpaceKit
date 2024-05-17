import MultiversX
import XCTest

@Contract
struct CounterContract {
    @Storage(key: "globalCounter") var globalCounter: BigUint
    
    public mutating func increaseByOne() {
        self.globalCounter += 1
    }
    
    public func getGlobalCounterValue() -> MXString {
        "The global counter is: \(self.globalCounter)"
    }
}

final class ContractStorageTests: ContractTestCase {
    
    func testGetCounterBeforeAnyIncrease() throws {
        let contract = CounterContract.testable("counter")
        
        let globalCounterValue = contract.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 0")
    }
    
    func testIncreaseCounterOnce() throws {
        var contract = CounterContract.testable("counter")
        
        contract.increaseByOne()
        
        let globalCounterValue = contract.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 1")
    }
    
    func testIncreaseCounterTwice() throws {
        var contract = CounterContract.testable("counter")
        
        contract.increaseByOne()
        contract.increaseByOne()
        
        let globalCounterValue = contract.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 2")
    }
    
    func testIncreaseCounterTwoContracts() throws {
        var contract1 = CounterContract.testable("counter1")
        contract1.increaseByOne()
        
        var contract2 = CounterContract.testable("counter2")
        contract2.increaseByOne()
        contract2.increaseByOne()
        
        let contract1GlobalCounterValue = contract1.getGlobalCounterValue()
        let contract2GlobalCounterValue = contract2.getGlobalCounterValue()
        
        XCTAssertEqual(contract1GlobalCounterValue, "The global counter is: 1")
        XCTAssertEqual(contract2GlobalCounterValue, "The global counter is: 2")
    }
    
}
