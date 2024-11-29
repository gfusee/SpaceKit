import SpaceKit
import XCTest

@Proxy enum DummyProxy {
    case endpointWithoutParameter
}

@Contract struct CodableMacroEnumImplTestsContract {
    // Temp test which has for sole goal to compile
    // TODO: add real tests once the SwiftVM supports async calls
    public func testRegisterPromise() {
        let dummyContractCall = ContractCall(
            receiver: Address(),
            endpointName: "dummyEndpoint",
            argBuffer: ArgBuffer()
        )
        
        dummyContractCall.registerPromise(
            gas: 0,
            callback: self.$testCallbackWithoutArgumentNorReturn(gasForCallback: 0)
        )
    }
    
    // Temp test which has for sole goal to compile
    // TODO: add real tests once the SwiftVM supports async calls
    // TODO: Does this test really has something to do in the @Callback tests?
    public func testRegisterPromiseNoCallback() {
        let dummyContractCall = ContractCall(
            receiver: Address(),
            endpointName: "dummyEndpoint",
            argBuffer: ArgBuffer()
        )
        
        dummyContractCall.registerPromise(
            gas: 0
        )
    }
    
    // Temp test which has for sole goal to compile
    // TODO: add real tests once the SwiftVM supports async calls
    // TODO: Does this test really has something to do in the @Callback tests?
    public func testRegisterPromiseThroughProxyNoCallback() {
        DummyProxy
            .endpointWithoutParameter
            .registerPromise(
                receiver: Address(),
                gas: 0
            )
    }
    
    // Temp test which has for sole goal to compile
    // TODO: add real tests once the SwiftVM supports async calls
    public func testRegisterPromiseThroughProxy() {
        DummyProxy
            .endpointWithoutParameter
            .registerPromise(
                receiver: Address(),
                gas: 0,
                callback: self.$testCallbackWithoutArgumentNorReturn(gasForCallback: 0)
            )
    }
    
    // Temp test which has for sole goal to compile
    // TODO: add real tests once the SwiftVM supports async calls
    public func testRegisterPromiseWithArgsThroughProxy() {
        DummyProxy
            .endpointWithoutParameter
            .registerPromise(
                receiver: Address(),
                gas: 0,
                callback: self.$testCallbackWithParametersNoReturn(firstArg: "", 0, dummy: Address(), gasForCallback: 0)
            )
    }
    
    @Callback public func testCallbackWithoutArgumentNorReturn() {}
    @Callback public func testCallbackWithParametersNoReturn(firstArg: Buffer, _ secondArg: BigUint, dummy thirdArg: Address) {}
}

final class CallbackMacroImplTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
}
