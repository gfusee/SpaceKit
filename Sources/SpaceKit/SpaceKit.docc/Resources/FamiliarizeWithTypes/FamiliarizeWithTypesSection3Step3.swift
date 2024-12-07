import SpaceKit

@Controller struct MyController {
    public func myEndpoint() {
        let initialNumber: BigUint = 5
        
        var result = initialNumber + 3
    }
}
