/*public struct CallbackData {
    let argBuffer: ArgBuffer
    
    public init(argBuffer: ArgBuffer) {
        self.argBuffer = argBuffer
    }
}

public struct CallbackDataBuilder {
    let name: StaticString
    
    public func callAsFunction(args: ArgBuffer) -> CallbackData {
        return CallbackData(argBuffer: args)
    }
}

public struct CallbackClosure<each CallbackArgs: TopEncodeMulti & TopDecode> {
    public typealias Closure = (repeat each CallbackArgs) -> ()
    
    let callback: Closure
    
    public init(callback: @escaping Closure) {
        self.callback = callback
    }
}

@propertyWrapper public struct Callback<each CallbackArgs: TopEncodeMulti & TopDecode> {
    public typealias Closure = CallbackClosure<repeat each CallbackArgs>
    
    let name: StaticString
    let callback: Closure
    
    public init(wrappedValue: Closure, name: StaticString) {
        self.callback = wrappedValue
        self.name = name
    }
    
    public var wrappedValue: Closure {
        self.callback
    }
    
    public var projectedValue: CallbackDataBuilder {
        CallbackDataBuilder(name: self.name)
    }
}
*/
