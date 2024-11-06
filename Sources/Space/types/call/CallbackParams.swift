public struct CallbackParams {
    public let name: StaticString
    public let args: ArgBuffer
    public let gas: UInt64
    
    public init(name: StaticString, args: ArgBuffer, gas: UInt64) {
        self.name = name
        self.args = args
        self.gas = gas
    }
}
