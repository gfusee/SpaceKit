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
    
}



/*
 func testIncreaseCounterTwoContracts() throws {
     let dummyAddress1 = "counter1"
     var contract1 = CounterContract.testable(address: dummyAddress1)
     contract1.increaseByOne()
     
     let dummyAddress2 = "counter2"
     var contract2 = CounterContract.testable(address: dummyAddress2)
     contract2.increaseByOne()
     contract2.increaseByOne()
     
     let contract1StoredValue = contract1.getStoredValue()
     let contract2StoredValue = contract2.getStoredValue()
     
     XCTAssertEqual(contract1StoredValue, "The counter is: 1")
     XCTAssertEqual(contract2StoredValue, "The counter is: 2")
 }
 */
