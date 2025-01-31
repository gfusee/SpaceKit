#if !WASM
import Foundation

public protocol TestableContract {
    init(address: String)
}

public protocol SwiftVMCompatibleContract {
    associatedtype TestableContractType: TestableContract
    
    init()
    
    static func __contractInit()
}
#endif
