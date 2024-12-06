import XCTest
import SpaceKit

@Controller struct FactorialController {
    public func factorial(value: BigUint) -> BigUint {
        let one: BigUint = 1
        
        if value == 0 {
            return one
        }
        
        var result: BigUint = 1
        var x: BigUint = 1
        
        while x <= value {
            result = result * x
            x = x + 1
        }
        
        return result
    }
}

final class FactorialTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "factorial",
                controllers: [
                    FactorialController.self
                ]
            )
        ]
    }
    
    func testZero() throws {
        try self.deployContract(at: "factorial")
        let controller = self.instantiateController(FactorialController.self, for: "factorial")!
        
        let result = try controller.factorial(value: 0)
        
        XCTAssertEqual(result, 1)
    }
    
    func testOne() throws {
        try self.deployContract(at: "factorial")
        let controller = self.instantiateController(FactorialController.self, for: "factorial")!
        
        let result = try controller.factorial(value: 1)
        
        XCTAssertEqual(result, 1)
    }
    
    func testTen() throws {
        try self.deployContract(at: "factorial")
        let controller = self.instantiateController(FactorialController.self, for: "factorial")!
        
        let result = try controller.factorial(value: 10)
        
        XCTAssertEqual(result, 3628800)
    }
    
}
