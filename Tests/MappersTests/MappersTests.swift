import SpaceKitTesting

@Init func initialize(
    initialBigUint: BigUint
) {
    let controller = MappersTestsController()
    controller.getBigUintSingleValueMapper().set(initialBigUint)
}

@Controller public struct MappersTestsController {
    public func getBigUintSingleValueMapper() -> SingleValueMapper<BigUint> {
        SingleValueMapper(baseKey: "bigUintSingleValueMapper")
    }
}

final class MappersTests: ContractTestCase {
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    MappersTestsController.self
                ]
            )
        ]
    }
    
    func testGetBigUintMapper() throws {
        try self.deployContract(at: "contract", arguments: [BigUint(value: UInt8(5))])
        let controller = self.instantiateController(MappersTestsController.self, for: "contract")!
        
        let result: BigUint = try controller.getBigUintSingleValueMapper()
        
        XCTAssertEqual(result, 5)
    }
}
