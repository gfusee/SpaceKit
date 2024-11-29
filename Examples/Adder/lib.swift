import SpaceKit

@Contract struct Adder {
    @Storage(key: "sum") var sum: BigUint
    
    init(initialValue: BigUint) {
        self.sum = initialValue
    }
    
    public mutating func add(value: BigUint) {
        self.sum = self.sum + value
    }
    
    public func getSum() -> BigUint {
        return self.sum
    }
}
