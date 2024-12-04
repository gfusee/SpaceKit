public protocol TopDecodeMulti {
    #if !WASM
    // Let's suppose we have an endpoint that returns a SetMapper<Address>.
    // When calling the endpoint in the SwiftVM we expect a Vector<Address> instead of a SetMapper<Address>.
    associatedtype SwiftVMDecoded
    
    static func fromTopDecodeMultiInput(_ input: inout some TopDecodeMultiInput) -> SwiftVMDecoded
    #endif
    
    init(topDecodeMulti input: inout some TopDecodeMultiInput)
}

#if !WASM
public extension TopDecodeMulti {
    typealias SwiftVMDecoded = Self
    
    static func fromTopDecodeMultiInput(_ input: inout some TopDecodeMultiInput) -> Self {
        return Self(topDecodeMulti: &input)
    }
}
#endif

public extension TopDecodeMulti where Self: TopDecode {
    @inline(__always)
    init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        self = Self(topDecode: input.nextValueInput())
    }
}
