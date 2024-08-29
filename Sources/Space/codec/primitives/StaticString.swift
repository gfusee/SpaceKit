extension StaticString: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        Buffer(stringLiteral: self).depEncode(dest: &dest)
    }
}

#if WASM
typealias String = StaticString
#endif
