public protocol SpaceSequence {
    associatedtype V
    
    func forEach(_ operations: (V) throws -> Void) rethrows
}
