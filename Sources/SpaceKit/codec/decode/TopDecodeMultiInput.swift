public protocol TopDecodeMultiInput {
    func hasNext() -> Bool
    mutating func nextValueInput() -> Buffer
}
