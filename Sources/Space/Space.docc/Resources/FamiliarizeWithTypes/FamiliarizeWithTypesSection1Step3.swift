import Space
import Foundation // Don't do this

@Contract struct MyContract {
    public func myEndpoint() {
        let myString: String = "Hey!" // Won't compile! ❌
        let myArray: [Int] = [7, 8, 100] // Won't compile! ❌
        
        let myInteger: UInt64 = 16 // Fine ✅
        let myBuffer: Buffer = "Hey!" // Fine ✅
    }
}
