import SpaceKitTesting

@Init func initialize(initialValue: BigUint) {
    var controller = AdderController()
    
    controller.sum = initialValue
}

@Controller public struct AdderController {
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
            WorldAccount(
                address: "adder",
                controllers: [
                    AdderController.self
                ]
            )
        ]
    }

    func testDeployAdderInitialValueZero() throws {
        try self.deployContract(
            at: "adder",
            arguments: [
                0
            ]
        )
        
        let controller = self.instantiateController(AdderController.self, for: "adder")!

        let result = try controller.getSum()

        XCTAssertEqual(result, 0)
    }

    func testDeployAdderInitialValueNonZero() throws {
        try self.deployContract(
            at: "adder",
            arguments: [
                15
            ]
        )
        
        let controller = self.instantiateController(AdderController.self, for: "adder")!

        let result = try controller.getSum()

        XCTAssertEqual(result, 15)
    }

    func testAddZero() throws {
        try self.deployContract(
            at: "adder",
            arguments: [
                15
            ]
        )
        
        var controller = self.instantiateController(AdderController.self, for: "adder")!

        try controller.add(value: 0)

        let result = try controller.getSum()

        XCTAssertEqual(result, 15)
    }

    func testAddNonZero() throws {
        try self.deployContract(
            at: "adder",
            arguments: [
                15
            ]
        )
        
        var controller = self.instantiateController(AdderController.self, for: "adder")!

        try controller.add(value: 5)

        let result = try controller.getSum()

        XCTAssertEqual(result, 20)
    }
}
