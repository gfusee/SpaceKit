public protocol TopEncode {
    func topEncode<T: TopEncodeOutput>(output: inout T)
}
