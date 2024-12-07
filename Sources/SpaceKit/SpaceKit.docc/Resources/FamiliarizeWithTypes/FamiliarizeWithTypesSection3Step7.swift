import SpaceKit

@Controller struct MyController {
    public func myEndpoint() {
        let initialNumber: BigUint = 5
        
        var result = initialNumber + 3
        result = result * 7
        result = result + initialNumber * 3
        result = result - 21
        
        guard result % 10 == 0 else {
            smartContractError(message: "result is not a multiple of 10")
        }
    }
}
