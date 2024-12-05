import SpaceKit

@Controller public struct Counter {
    @Storage(key: "counter") var counter: BigUint
    
    init(initialValue: BigUint) {
        self.counter = initialValue
    }
    
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
