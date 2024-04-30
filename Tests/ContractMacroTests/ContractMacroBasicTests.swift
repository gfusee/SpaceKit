import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import ContractMacro

let testMacros: [String: Macro.Type] = [
    "Contract": Contract.self,
]

final class ContractMacroBasicTests: XCTestCase {
    func testExpandClassShouldFail() throws {
        let source = """
        @Contract
        class Contract {}
        """
        
        let expected = """
        class Contract {}
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Contract can only be applied to a structure.",
                    line: 1,
                    column: 1
                ),
                DiagnosticSpec(
                    message: "@Contract can only be applied to a structure.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandEmptyStruct() throws {
        let source = """
        @Contract
        struct Contract {}
        """

        let expected = """
        struct Contract {
        
            init() {
            }

            init(_noDeploy: ()) {
            }
        
            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
            }
            #endif}
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandStructWithTwoInitShouldFail() throws {
        let source = """
        @Contract
        struct Contract {
            init(arg: Int) {}
            init(arg: String) {}
        }
        """

        let expected = """
        struct Contract {
            init(arg: Int) {}
            init(arg: String) {}
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "Only one or zero initializer is allowed in a structure marked @Contract.",
                    line: 1,
                    column: 1
                ),
                DiagnosticSpec(
                    message: "Only one or zero initializer is allowed in a structure marked @Contract.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandNonPublicFunctionStruct() throws {
        let source = """
        @Contract
        struct Contract {
            func notAnEndpoint() {}
        }
        """

        let expected = """
        struct Contract {
            func notAnEndpoint() {}
        
            init() {
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleVoidInitStruct() throws {
        let source = """
        @Contract
        struct Contract {
            init() {
                let testBuffer: MXBuffer = "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            init() {
                let testBuffer: MXBuffer = "Hello World!"
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleOneParamInitStruct() throws {
        let source = """
        @Contract
        struct Contract {
            init(buffer: MXBuffer) {
                let testBuffer: MXBuffer = "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            init(buffer: MXBuffer) {
                let testBuffer: MXBuffer = "Hello World!"
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String, buffer: MXBuffer) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { (buffer: MXBuffer) in
                let _ = Contract(buffer: buffer)
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleTwoParamsInitStruct() throws {
        let source = """
        @Contract
        struct Contract {
            init(buffer: MXBuffer, number: BigUint) {
                let testBuffer: MXBuffer = "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            init(buffer: MXBuffer, number: BigUint) {
                let testBuffer: MXBuffer = "Hello World!"
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String, buffer: MXBuffer, number: BigUint) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { (buffer: MXBuffer, number: BigUint) in
                let _ = Contract(buffer: buffer, number: number)
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleVoidFunctionStruct() throws {
        let source = """
        @Contract
        struct Contract {
            public func singleFunction() {
        
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction() {
        
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }
        
            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
                    public func singleFunction() {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "singleFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract(_noDeploy: ())
                        return contract.singleFunction()
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            withTransactionArguments { () in
                var contract = Contract(_noDeploy: ())
                contract.singleFunction()
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleOneParamFunctionStruct() throws {
        let source = """
        @Contract
        struct Contract {
            public func singleFunction(buffer: MXBuffer) {
                
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction(buffer: MXBuffer) {
                
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }
        
            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
                    public func singleFunction(buffer: MXBuffer) {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "singleFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract(_noDeploy: ())
                        return contract.singleFunction(buffer: buffer)
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            withTransactionArguments { (buffer: MXBuffer) in
                var contract = Contract(_noDeploy: ())
                contract.singleFunction(buffer: buffer)
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleTwoParamsFunctionStruct() throws {
        let source = """
        @Contract
        struct Contract {
            public func singleFunction(buffer: MXBuffer, number: BigUint) {
                
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction(buffer: MXBuffer, number: BigUint) {
                
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }
        
            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
                    public func singleFunction(buffer: MXBuffer, number: BigUint) {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "singleFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract(_noDeploy: ())
                        return contract.singleFunction(buffer: buffer, number: number)
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            withTransactionArguments { (buffer: MXBuffer, number: BigUint) in
                var contract = Contract(_noDeploy: ())
                contract.singleFunction(buffer: buffer, number: number)
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleFunctionWithReturnStruct() throws {
        let source = """
        @Contract
        struct Contract {
            public func singleFunction() -> MXBuffer {
                return "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction() -> MXBuffer {
                return "Hello World!"
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
                    public func singleFunction() -> MXBuffer {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "singleFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract(_noDeploy: ())
                        return contract.singleFunction()
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }
        
        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            withTransactionArguments { () in
                var result = MXBuffer()

                var contract = Contract(_noDeploy: ())
                let endpointOutput = contract.singleFunction()

                endpointOutput.topEncode(output: &result)

                result.finish()
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandMultipleFunctionsStruct() throws {
        let source = """
        @Contract
        struct Contract {
            public func firstFunction() {
        
            }
        
            public func secondFunction() {
            
            }
        }
        """

        let expected = """
        struct Contract {
            public func firstFunction() {

            }

            public func secondFunction() {
            
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(address: _testableAddress)
            }

            public struct Testable {
                let address: String
                    public func firstFunction() {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "firstFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract(_noDeploy: ())
                        return contract.firstFunction()
                    }
                }

                    public func secondFunction() {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "secondFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract(_noDeploy: ())
                        return contract.secondFunction()
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            withTransactionArguments { () in
                let _ = Contract()
            }
        }

        @_expose(wasm, "firstFunction")
        @_cdecl("firstFunction") func __macro_local_13firstFunctionfMu_() {
            withTransactionArguments { () in
                var contract = Contract(_noDeploy: ())
                contract.firstFunction()
            }
        }

        @_expose(wasm, "secondFunction")
        @_cdecl("secondFunction") func __macro_local_14secondFunctionfMu_() {
            withTransactionArguments { () in
                var contract = Contract(_noDeploy: ())
                contract.secondFunction()
            }
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
}
