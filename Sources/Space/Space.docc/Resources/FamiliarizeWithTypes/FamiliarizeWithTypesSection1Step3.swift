import Space

@Contract struct MyContract {
    public func myEndpoint() {
        let myString: String = "Hey!" // Won't compile! ❌
        let myBuffer: Buffer = "Hey!" // Fine ✅
        
        let myArray: [UInt64] = [4, 8, 100] // Won't compile! ❌
    }
}
