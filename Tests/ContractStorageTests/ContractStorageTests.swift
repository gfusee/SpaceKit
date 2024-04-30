import MultiversX
import XCTest

@Contract
struct CounterContract {
    @Storage(key: "counter") var counter: BigUint
    
    public mutating func increaseByOne() {
        self.counter += 1
    }
    
    public func getCounterValue() -> MXString {
        "The counter is: \(self.counter)"
    }
}












final class ContractStorageTests: ContractTestCase {
    
    func testGetCounterBeforeAnyIncrease() throws {
        let contract = CounterContract.testable(address: "counter")
        
        let counterValue = contract.getCounterValue()
        
        XCTAssertEqual(counterValue, "The counter is: 0")
    }
    
    func testIncreaseCounterOnce() throws {
        var contract = CounterContract.testable(address: "counter")
        
        contract.increaseByOne()
        
        let counterValue = contract.getCounterValue()
        
        XCTAssertEqual(counterValue, "The counter is: 1")
    }
    
    func testIncreaseCounterTwice() throws {
        let dummyAddress = "counter"
        var contract = CounterContract.testable(address: dummyAddress)
        
        contract.increaseByOne()
        contract.increaseByOne()
        
        let counterValue = contract.getCounterValue()
        
        XCTAssertEqual(counterValue, "The counter is: 2")
    }
    
    func testIncreaseCounterTwoContracts() throws {
        var contract1 = CounterContract.testable(address: "counter1")
        contract1.increaseByOne()
        
        var contract2 = CounterContract.testable(address: "counter2")
        contract2.increaseByOne()
        contract2.increaseByOne()
        
        let contract1StoredValue = contract1.getCounterValue()
        let contract2StoredValue = contract2.getCounterValue()
        
        XCTAssertEqual(contract1StoredValue, "The counter is: 1")
        XCTAssertEqual(contract2StoredValue, "The counter is: 2")
    }
    
}
