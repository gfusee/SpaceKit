import Space
import Counter
import XCTest

let COUNTER_ADDRESS = "counter"

final class CounterTests: ContractTestCase {
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: COUNTER_ADDRESS)
        ]
    }
    
    func testDeployCounterInitialValueZero() throws {
        let contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 0
        )
        
        let result = try contract.getCounter()
        
        XCTAssertEqual(result, 0)
    }
    
    func testDeployCounterInitialValueNonZero() throws {
        let contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 15
        )
        
        let result = try contract.getCounter()
        
        XCTAssertEqual(result, 15)
    }
    
    func testIncreaseZero() throws {
        var contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 15
        )
        
        try contract.increase(value: 0)
        
        let result = try contract.getCounter()
        
        XCTAssertEqual(result, 15)
    }
    
    func testIncreaseMoreThanZero() throws {
        var contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 15
        )
        
        try contract.increase(value: 5)
        
        let result = try contract.getCounter()
        
        XCTAssertEqual(result, 20)
    }
}