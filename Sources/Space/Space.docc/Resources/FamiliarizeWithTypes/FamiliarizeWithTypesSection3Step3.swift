import Space

@Contract struct MyContract {
    public func myEndpoint() {
        let initialNumber: BigUint = 5
        
        var result = initialNumber + 3
    }
}
