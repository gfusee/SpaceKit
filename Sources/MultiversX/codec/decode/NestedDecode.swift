public protocol NestedDecode {
    static func depDecode<I: NestedDecodeInput>(input: inout I) -> Self
}
