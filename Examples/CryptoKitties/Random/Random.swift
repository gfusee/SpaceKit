import Space

// WARNING: to anyone reading this code. This is a reproduction of the Rust example, however the below Swift code is not a good practice in its current state. This is because of all the bytes manipulations done in Buffer instead of static arrays, which are not available in Swift at the moment.

let SEED_SIZE: UInt32 = 48
let SALT_SIZE: UInt32 = 32
let BYTE_MAX: UInt16 = UInt16(UInt8.max) + 1

public struct Random {
    private(set) var data: Buffer
    private(set) var currentIndex: UInt32
    
    public init(
        seed: Buffer,
        salt: Buffer
    ) {
        require(
            seed.count == SEED_SIZE,
            "Wrong seed size"
        )
        
        require(
            salt.count == SALT_SIZE,
            "Wrong salt size"
        )
        
        let bufferOfSize8 = Buffer(data: getZeroedBytes8())
        var randomSource = Buffer(data: getZeroedBytes32()) + bufferOfSize8 + bufferOfSize8
        
        // Read the warning on top of this file before reading this function
        for i in 0..<SEED_SIZE {
            // TODO: Swift doesn't support fixed-size arrays, so this is super tricky and will consume a lot of gas
            let seedByte = seed.getSubBuffer(startIndex: Int32(i), length: 1).toBigEndianBytes8().7
            let saltByte = salt.getSubBuffer(startIndex: Int32(i % SALT_SIZE), length: 1).toBigEndianBytes8().7
            let sum = UInt16(seedByte) + UInt16(saltByte)
            
            randomSource = randomSource.withReplaced(startingPosition: Int32(i), with: Buffer(data: UInt8(sum % BYTE_MAX)))
        }
        
        self.data = randomSource
        self.currentIndex = 0
    }
    
    // Read the warning on top of this file before reading this function
    public mutating func nextU8() -> UInt8 {
        let byteBuffer = self.data.getSubBuffer(startIndex: Int32(self.currentIndex), length: 1)
        let val = byteBuffer.toBigEndianBytes8().7
        
        self.currentIndex += 1
        
        if self.currentIndex == SEED_SIZE {
            self.shuffle()
            self.currentIndex = 0
        }
        
        return val
    }
    
    // TODO: Here is a todo comment present in the Rust code: "Fix, this only generates in u8 range". We keep this as is since the goal is to pass the same scenario tests as the Rust contract. We should fix this when it is fixed in the Rust example
    public mutating func nextU32() -> UInt32 {
        let firstByte = UInt32(self.nextU8())
        let secondByte = UInt32(self.nextU8())
        let thirdByte = UInt32(self.nextU8())
        let fourthByte = UInt32(self.nextU8())
        
        return firstByte | secondByte | thirdByte | fourthByte
    }
    
    // Read the warning on top of this file before reading this function
    public mutating func shuffle() {
        for i in 0..<(SEED_SIZE - 1) {
            let iByte = UInt16(self.data.getSubBuffer(startIndex: Int32(i), length: 1).toBigEndianBytes8().7)
            let iPlusOneByte = UInt16(self.data.getSubBuffer(startIndex: Int32(i) + 1, length: 1).toBigEndianBytes8().7)
            
            let res: UInt16 = iByte + iPlusOneByte + 1
            
            self.data = self.data.withReplaced(startingPosition: Int32(i), with: Buffer(data: UInt8(res % BYTE_MAX)))
        }
    }
}
