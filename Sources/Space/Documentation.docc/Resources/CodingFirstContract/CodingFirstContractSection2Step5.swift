import Space

@Contract public struct Counter {
    @Storage(key: "counter") var counter: BigUint
    
    init(initialValue: BigUint) {
        self.counter = initialValue
    }
}
