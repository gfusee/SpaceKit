import SpaceKit

@Controller struct FactorialController {
    public func testEndpoint() {
        let callback = self.$dummyCallback(arg: 4, gasForCallback: 50000000)
        
        guard Buffer(stringLiteral: callback.name) == "dummyCallback" else { // To be sure the compiler includes the $ function
            smartContractError(message: "")
        }
    }
    
    @Callback public func dummyCallback(arg: BigUint) {
        smartContractError(message: "should never be executed")
    }
}
