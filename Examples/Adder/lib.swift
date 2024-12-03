import SpaceKit

@Init func initialize(initialValue: BigUint) {
    var controller = Adder()
    
    controller.sum = initialValue
}

@Contract struct Adder {
    @Storage(key: "sum") var sum: BigUint
    
    public mutating func add(value: BigUint) {
        self.sum = self.sum + value
    }
    
    public func getSum() -> BigUint {
        return self.sum
    }
}
