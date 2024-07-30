public protocol TopEncodeMulti {
    func multiEncode<O: TopEncodeMultiOutput>(output: inout O)
}

public extension TopEncodeMulti where Self: TopEncode {
    @inline(__always)
    func multiEncode<O: TopEncodeMultiOutput>(output: inout O) {
        output.pushSingleValue(arg: self)
    }
}
