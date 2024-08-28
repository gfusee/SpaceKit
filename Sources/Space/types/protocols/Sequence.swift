public protocol MXSequence {
    associatedtype V
    
    func forEach(_ operations: (V) throws -> Void) rethrows
}
