import SpaceKit

@Contract public struct Counter {
    @Storage(key: "counter") var counter: BigUint
    
    init(initialValue: BigUint) {
        self.counter = initialValue
    }
    
    public mutating func increase(value: BigUint) {
        self.counter = self.counter + value
    }
}
