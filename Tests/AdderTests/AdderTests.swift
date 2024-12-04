import SpaceKit
import XCTest

@Init func initialize(initialValue: BigUint) {
    var controller = Adder()
    
    controller.sum = initialValue
}

@Contract struct Adder {
    @Storage(key: "sum") var sum: BigUint
    
    public mutating func add(value: BigUint) {
        self.sum += value
    }

    public func getSum() -> BigUint {
        self.sum
    }
}

final class AdderTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "adder")
        ]
    }

    func testDeployAdderInitialValueZero() throws {
        let contract = try self.deployContract(
            Adder.self,
            at: "adder",
            arguments: [
                0
            ]
        )

        let result = try contract.getSum()

        XCTAssertEqual(result, 0)
    }

    func testDeployAdderInitialValueNonZero() throws {
        let contract = try self.deployContract(
            Adder.self,
            at: "adder",
            arguments: [
                15
            ]
        )

        let result = try contract.getSum()

        XCTAssertEqual(result, 15)
    }

    func testAddZero() throws {
        var contract = try self.deployContract(
            Adder.self,
            at: "adder",
            arguments: [
                15
            ]
        )

        try contract.add(value: 0)

        let result = try contract.getSum()

        XCTAssertEqual(result, 15)
    }

    func testAddNonZero() throws {
        var contract = try self.deployContract(
            Adder.self,
            at: "adder",
            arguments: [
                15
            ]
        )

        try contract.add(value: 5)

        let result = try contract.getSum()

        XCTAssertEqual(result, 20)
    }
}
