#if !WASM
import XCTest

open class ContractTestCase: XCTestCase {
    
    open override func setUp() {
        super.setUp()
        
        API.resetWorld()
    }
    
}

#endif
