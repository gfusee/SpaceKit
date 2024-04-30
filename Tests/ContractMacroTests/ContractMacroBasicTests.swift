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
        
            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
            }
            #endif}
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract.init()
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandStructWithInitShouldFail() throws {
        let source = """
        @Contract
        struct Contract {
            init() {}
        }
        """

        let expected = """
        struct Contract {
            init() {}

            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "Only one or zero convenience initializer is allowed in a structure marked @Contract.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandStructWithTwoConvenienceInitShouldFail() throws {
        let source = """
        @Contract
        struct Contract {
            convenience init(arg: Int) {}
            convenience init(arg: String) {}
        }
        """

        let expected = """
        struct Contract {
            convenience init(arg: Int) {}
            convenience init(arg: String) {}

            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "Only one or zero convenience initializer is allowed in a structure marked @Contract.",
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

            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract.init()
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleConvenienceVoidInitStruct() throws {
        let source = """
        @Contract
        struct Contract {
            convenience init() {}
        }
        """

        let expected = """
        struct Contract {
            convenience init() {}

            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract.init()
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
        
            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
                    public func singleFunction() {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "singleFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract .init()
                        return contract.singleFunction()
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract.init()
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            var contract = Contract()
            contract.singleFunction()
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

            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
                    public func singleFunction() -> MXBuffer {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "singleFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract .init()
                        return contract.singleFunction()
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract.init()
        }
        
        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            var result = MXBuffer()
        
            var contract = Contract()
            let endpointOutput = contract.singleFunction()
        
            endpointOutput.topEncode(output: &result)
        
            result.finish()
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

            #if !WASM
            public static func testable(address: String) -> Testable {
                Testable(address: address)
            }

            public struct Testable {
                let address: String
                    public func firstFunction() {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "firstFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract .init()
                        return contract.firstFunction()
                    }
                }

                    public func secondFunction() {
                    return runTestCall(
                        contractAddress: self.address,
                        endpointName: "secondFunction",
                        hexEncodedArgs: []
                    ) {
                        var contract = Contract .init()
                        return contract.secondFunction()
                    }
                }
            }
            #endif
        }
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract.init()
        }

        @_expose(wasm, "firstFunction")
        @_cdecl("firstFunction") func __macro_local_13firstFunctionfMu_() {
            var contract = Contract()
            contract.firstFunction()
        }

        @_expose(wasm, "secondFunction")
        @_cdecl("secondFunction") func __macro_local_14secondFunctionfMu_() {
            var contract = Contract()
            contract.secondFunction()
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
}
