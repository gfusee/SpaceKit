import MultiversX

@Contract
struct Adder {
    @Storage(key: "sum") var sum: BigUint
    
    public mutating func add(value: BigUint) {
        self.sum += value
    }
    
    public func getSum() -> BigUint {
        self.sum
    }
}
