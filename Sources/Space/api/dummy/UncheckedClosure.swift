#if !WASM
package struct UncheckedClosure: @unchecked Sendable {
    typealias Closure = () -> Void

    let closure: Closure

    init(_ closure: @escaping Closure) {
        self.closure = closure
    }
}
#endif
