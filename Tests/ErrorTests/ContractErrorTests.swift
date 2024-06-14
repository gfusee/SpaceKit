import MultiversX
import XCTest

@Contract struct ErrorContract {
    
    public func throwError(errorMessage: MXBuffer) {
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
            WorldAccount(address: "contract")
        ]
    }
    
    func testUserError() throws {
        let contract = try ErrorContract.testable("contract")
        
        do {
            try contract.throwError(errorMessage: "This is an user error message")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "This is an user error message"))
        }
    }
    
    func testUserErrorThroughRequire() throws {
        let contract = try ErrorContract.testable("contract")
        
        do {
            try contract.throwErrorThroughRequire()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "This is an user error through require"))
        }
    }
    
    func testRequireNoError() throws {
        let contract = try ErrorContract.testable("contract")
        
        try contract.dontThrowErrorThroughRequire()
    }
    
}
