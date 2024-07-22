import MultiversX
import XCTest

@Proxy enum TestProxy {
    case endpointWithoutParameter
    case endpointWithOneParameter(arg: BigUint), endpointOnTheSameLine(arg: MXBuffer)
    case endpointWithMultipleParameters(firstArg: BigUint, secondArg: MXBuffer)
    case endpointWithNonNamedParameters(BigUint, MXBuffer)
}

final class TransferAndExecuteTests: ContractTestCase {
    
    func test() throws {}
    
}
