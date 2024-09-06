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
    
    func testDecreaseZero() throws {
        var contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 15
        )
        
        try contract.decrease(value: 0)
        
        let result = try contract.getCounter()
        
        XCTAssertEqual(result, 15)
    }
    
    func testDecreaseMoreThanZero() throws {
        var contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 15
        )
        
        try contract.decrease(value: 5)
        
        let result = try contract.getCounter()
        
        XCTAssertEqual(result, 10)
    }
    
    func testDecreaseTooMuchShouldFail() throws {
        let contract = try Counter.testable(
            COUNTER_ADDRESS,
            initialValue: 15
        )
        
        do {
            try contract.decrease(value: 16)
            
            XCTFail() // Decrease fails, so this line should not be executed
        } catch {
            XCTAssertEqual(error, .userError(message: "cannot subtract because result would be negative"))
        }
    }
}
