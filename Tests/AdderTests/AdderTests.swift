import MultiversX
import XCTest

@Contract
struct Adder {
    @Storage(key: "sum") var sum: BigUint
    
    init(initialValue: BigUint) {
        self.sum = initialValue
    }
    
    public mutating func add(value: BigUint) {
        self.sum += value
    }
    
    public func getSum() -> BigUint {
        self.sum
    }
}

final class AdderTests: ContractTestCase {
    
    func testDeployAdderInitialValueZero() throws {
        let contract = Adder.testable("adder", initialValue: 0)
        
        let result = contract.getSum()
        
        XCTAssertEqual(result, 0)
    }
    
    func testDeployAdderInitialValueNonZero() throws {
        let contract = Adder.testable("adder", initialValue: 15)
        
        let result = contract.getSum()
        
        XCTAssertEqual(result, 15)
    }
    
    func testAddZero() throws {
        var contract = Adder.testable("adder", initialValue: 15)
        
        contract.add(value: 0)
        
        let result = contract.getSum()
        
        XCTAssertEqual(result, 15)
    }
    
    func testAddNonZero() throws {
        var contract = Adder.testable("adder", initialValue: 15)
        
        contract.add(value: 5)
        
        let result = contract.getSum()
        
        XCTAssertEqual(result, 20)
    }
    
}
