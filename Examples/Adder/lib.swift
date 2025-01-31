import SpaceKit

@Init func initialize(initialValue: BigUint) {
    var controller = AdderController()
    
    controller.sum = initialValue
}

@Controller public struct AdderController {
    @Storage(key: "sum") var sum: BigUint
    
    public mutating func add(value: BigUint) {
        self.sum = self.sum + value
    }
    
    public func getSum() -> BigUint {
        return self.sum
    }
}
