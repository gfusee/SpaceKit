import Space

@Contract struct MyContract {
    public func myEndpoint() {
        let myString: String = "Hey!" // Won't compile! ❌
        let myBuffer: Buffer = "Hey!" // Fine ✅
        
        let myArray: [UInt64] = [4, 8, 100] // Won't compile! ❌
        var myVector: Vector<UInt64> = Vector() // Fine ✅
            .appended(4)
            .appended(8)
            .appended(100)
        
        let two = 2 // Fine ✅
        let ten: UInt64 = 10 // Fine ✅
        let isTwoEven = false // Fine ✅
    }
}
