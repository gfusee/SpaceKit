public protocol TopEncodeMulti {
    func multiEncode<O: TopEncodeMultiOutput>(output: inout O)
}

public extension TopEncodeMulti where Self: TopEncode {
    func multiEncode<O: TopEncodeMultiOutput>(output: inout O) {
        output.pushSingleValue(arg: self)
    }
}
