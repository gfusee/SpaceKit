import Space

@Contract struct MyContract {
    public func myEndpoint() {
        let myString: String = "Hey!" // Won't compile! ❌
        let myBuffer: Buffer = "Hey!" // Fine ✅
    }
}
