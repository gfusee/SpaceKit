#if !WASM
extension String: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        Buffer(self).depEncode(dest: &dest)
    }
}
#endif
