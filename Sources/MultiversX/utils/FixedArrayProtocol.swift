public protocol FixedArrayProtocol {
    associatedtype T
    
    init(count: Int)
    
    var count: Int { get }
    
    mutating func withUnsafeMutableBufferPointer<R>(_ body: (UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R
}

extension FixedArray8: FixedArrayProtocol where T: ExpressibleByIntegerLiteral {}
