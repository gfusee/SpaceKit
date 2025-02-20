import SpaceKit

@Controller public struct CounterController {
    @Storage(key: "counter") var counter: BigUint
    
    public mutating func increase(value: BigUint) {
        self.counter = self.counter + value
    }
    
    public mutating func decrease(value: BigUint) {
        self.counter = self.counter - value
    }
}
