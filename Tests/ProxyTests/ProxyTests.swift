import MultiversX
import XCTest

@Proxy enum CalleeProxy {
    case endpointWithoutParameter
    case endpointWithOneParameter(arg: BigUint), endpointOnTheSameLine(arg: MXBuffer)
    case endpointWithMultipleParameters(firstArg: Int32, secondArg: MXBuffer)
    case endpointWithNonNamedParameters(Int32, MXBuffer)
    case throwError
}

@Contract struct CalleeContract {
    public mutating func endpointWithoutParameter() {}
    
    public mutating func endpointWithOneParameter(arg: BigUint) -> BigUint {
        return arg
    }
    
    public mutating func endpointWithMultipleParameters(firstArg: Int32, secondArg: MXBuffer) -> MXBuffer {
        var result = MXBuffer()
        
        for _ in 0...firstArg {
            result = result + secondArg
        }
        
        return result
    }
    
    public mutating func endpointWithNonNamedParameters(firstArg: Int32, secondArg: MXBuffer) -> MXBuffer {
        var result = MXBuffer()
        
        for _ in 0...firstArg {
            result = result + secondArg
        }
        
        return result
    }
    
    public mutating func throwError() {
        smartContractError(message: "This is an error")
    }
}

@Contract struct CallerContract {
    public mutating func callEndpointWithoutParameter(calleeAddress: Address) {
        CalleeProxy.endpointWithoutParameter.callAndIgnoreResult(receiver: calleeAddress)
    }
    
    public mutating func callEndpointWithOneParameter(calleeAddress: Address, arg: BigUint) -> BigUint {
        return CalleeProxy.endpointWithOneParameter(arg: arg).call(receiver: calleeAddress)
    }
    
    public mutating func callEndpointWithMultipleParameters(calleeAddress: Address, firstArg: Int32, secondArg: MXBuffer) -> MXBuffer {
        return CalleeProxy.endpointWithMultipleParameters(firstArg: firstArg, secondArg: secondArg).call(receiver: calleeAddress)
    }
    
    public mutating func callEndpointWithMultipleParametersNonNamed(calleeAddress: Address, firstArg: Int32, secondArg: MXBuffer) -> MXBuffer {
        return CalleeProxy.endpointWithNonNamedParameters(firstArg, secondArg).call(receiver: calleeAddress)
    }
    
    public mutating func callEndpointThrowError(calleeAddress: Address) {
        CalleeProxy.throwError.callAndIgnoreResult(receiver: calleeAddress)
    }
}

final class TransferAndExecuteTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "callee"),
            WorldAccount(address: "caller")
        ]
    }
    
    func testCallEndpointWithoutParameter() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        try caller.callEndpointWithoutParameter(calleeAddress: "callee")
    }
    
    func testCallEndpointWithOneParameter() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callEndpointWithOneParameter(calleeAddress: "callee", arg: 5)
        
        XCTAssertEqual(result, 5)
    }
    
    func testCallEndpointWithMultipleParameters() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callEndpointWithMultipleParameters(calleeAddress: "callee", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallEndpointWithNonNamedParameters() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callEndpointWithMultipleParametersNonNamed(calleeAddress: "callee", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallEndpointCalleeNotRegistered() throws {
        var caller = try CallerContract.testable("caller")
        
        do {
            try caller.callEndpointWithoutParameter(calleeAddress: "callee")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .worldError(message: "Contract not registered for address: \(self.getAccount(address: "callee")!.addressData.hexEncodedString())"))
        }
    }
    
    func testCallEndpointThrowError() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        do {
            try caller.callEndpointThrowError(calleeAddress: "callee")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "execution failed"))
        }
    }
    
}
