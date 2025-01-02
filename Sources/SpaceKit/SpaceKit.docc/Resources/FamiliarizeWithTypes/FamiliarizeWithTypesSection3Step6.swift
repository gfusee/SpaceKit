import SpaceKit

@Controller public struct MyController {
    public func myEndpoint() {
        let initialNumber: BigUint = 5
        
        var result = initialNumber + 3
        result = result * 7
        result = result + initialNumber * 3
        result = result - 21
    }
}
