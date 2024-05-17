public protocol NestedEncode {
    func depEncode<O: NestedEncodeOutput>(dest: inout O)
}
