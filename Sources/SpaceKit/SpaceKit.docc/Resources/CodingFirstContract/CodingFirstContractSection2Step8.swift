import SpaceKit

@Init func initialize(initialValue: BigUint) {
    var controller = CounterController()
    
    controller.counter = initialValue
}

@Controller public struct CounterController {
    @Storage(key: "counter") var counter: BigUint
    
    public mutating func increase(value: BigUint) {
        self.counter = self.counter + value
    }
    
    public mutating func decrease(value: BigUint) {
        self.counter = self.counter - value
    }
    
    public func getCounter() -> BigUint {
        return self.counter
    }
}
