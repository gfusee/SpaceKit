import SpaceKit
import SpaceKitTesting

@Controller public struct ErrorController {
    
    public func throwError(errorMessage: Buffer) {
        smartContractError(message: errorMessage)
    }
    
    public func throwErrorThroughRequire() {
        require(false, "This is an user error through require")
    }
    
    public func dontThrowErrorThroughRequire() {
        require(true, "This is an user error through require")
    }
    
}

final class ContractErrorTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    ErrorController.self
                ]
            )
        ]
    }
    
    func testUserError() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(ErrorController.self, for: "contract")!
        
        do {
            try controller.throwError(errorMessage: "This is an user error message")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "This is an user error message"))
        }
    }
    
    func testUserErrorThroughRequire() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(ErrorController.self, for: "contract")!
        
        do {
            try controller.throwErrorThroughRequire()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "This is an user error through require"))
        }
    }
    
    func testRequireNoError() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(ErrorController.self, for: "contract")!
        
        try controller.dontThrowErrorThroughRequire()
    }
    
}
