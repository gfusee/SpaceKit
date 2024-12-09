import SpaceKit
import Counter
import XCTest

let COUNTER_ADDRESS = "counter"

final class CounterTests: ContractTestCase {
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: COUNTER_ADDRESS,
                controllers: [
                    CounterController.self
                ]
            )
        ]
    }
    
    func testDeployCounterInitialValueZero() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                0 // Initial value
            ]
        )
        
        let controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
        
        let result = try controller.getCounter()
        
        XCTAssertEqual(result, 0)
    }
    
    func testDeployCounterInitialValueNonZero() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                15 // Initial value
            ]
        )
        
        let controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
        
        let result = try controller.getCounter()
        
        XCTAssertEqual(result, 15)
    }
    
    func testIncreaseZero() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                15 // Initial value
            ]
        )
        
        var controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
        
        try controller.increase(value: 0)
        
        let result = try controller.getCounter()
        
        XCTAssertEqual(result, 15)
    }
    
    func testIncreaseMoreThanZero() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                15 // Initial value
            ]
        )
        
        var controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
        
        try controller.increase(value: 5)
        
        let result = try controller.getCounter()
        
        XCTAssertEqual(result, 20)
    }
    
    func testDecreaseZero() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                15 // Initial value
            ]
        )
        
        var controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
        
        try controller.decrease(value: 0)
        
        let result = try controller.getCounter()
        
        XCTAssertEqual(result, 15)
    }
    
    func testDecreaseMoreThanZero() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                15 // Initial value
            ]
        )
        
        var controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
        
        try controller.decrease(value: 5)
        
        let result = try controller.getCounter()
        
        XCTAssertEqual(result, 10)
    }
    
    func testDecreaseTooMuchShouldFail() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                15 // Initial value
            ]
        )
        
        var controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
        
        do {
            try controller.decrease(value: 16)
            
            XCTFail() // Decrease fails, so this line should not be executed
        } catch {
            XCTAssertEqual(error, .userError(message: "cannot subtract because result would be negative"))
        }
    }
}
