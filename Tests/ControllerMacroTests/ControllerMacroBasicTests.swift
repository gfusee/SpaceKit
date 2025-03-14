import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import ControllerMacro

let testMacros: [String: Macro.Type] = [
    "Controller": Controller.self,
]

final class ControllerMacroBasicTests: XCTestCase {
    /*
    func testExpandClassShouldFail() throws {
        let source = """
        @Controller
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
                    message: "@Controller can only be applied to a structure.",
                    line: 1,
                    column: 1
                ),
                DiagnosticSpec(
                    message: "@Controller can only be applied to a structure.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
     
    func testExpandEmptyStruct() throws {
        let source = """
        @Controller
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
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
            }
            #endif}
        
        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract()
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
        @Controller
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
                    message: "Only one or zero initializer is allowed in a structure marked @Controller.",
                    line: 1,
                    column: 1
                ),
                DiagnosticSpec(
                    message: "Only one or zero initializer is allowed in a structure marked @Controller.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandNonPublicFunctionStruct() throws {
        let source = """
        @Controller
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
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract()
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
        @Controller
        struct Contract {
            init() {
                let testBuffer: Buffer = "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            init() {
                let testBuffer: Buffer = "Hello World!"
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            let _ = Contract()
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
        @Controller
        struct Contract {
            init(buffer: Buffer) {
                let testBuffer: Buffer = "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            init(buffer: Buffer) {
                let testBuffer: Buffer = "Hello World!"
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String, buffer: Buffer) -> Testable {
                Testable(_testableAddress, buffer: buffer)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String, buffer: Buffer) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract(buffer: buffer)
                    }
                }
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            var _argsLoader = EndpointArgumentsLoader()
            let buffer = Buffer(topDecodeMulti: &_argsLoader)
            let _ = Contract(buffer: buffer)
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
        @Controller
        struct Contract {
            init(buffer: Buffer, number: BigUint) {
                let testBuffer: Buffer = "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            init(buffer: Buffer, number: BigUint) {
                let testBuffer: Buffer = "Hello World!"
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String, buffer: Buffer, number: BigUint) -> Testable {
                Testable(_testableAddress, buffer: buffer, number: number)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String, buffer: Buffer, number: BigUint) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract(buffer: buffer, number: number)
                    }
                }
            }
            #endif
        }

        @_expose(wasm, "init")
        @_cdecl("init") func __macro_local_4initfMu_() {
            var _argsLoader = EndpointArgumentsLoader()
            let buffer = Buffer(topDecodeMulti: &_argsLoader)
            let number = BigUint(topDecodeMulti: &_argsLoader)
            let _ = Contract(buffer: buffer, number: number)
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
        @Controller
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
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
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
            let _ = Contract()
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            var _contract = Contract(_noDeploy: ())

            _contract.singleFunction()
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
        @Controller
        struct Contract {
            public func singleFunction(buffer: Buffer) {
                
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction(buffer: Buffer) {
                
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }
        
            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
                    public func singleFunction(buffer: Buffer) {
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
            let _ = Contract()
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            var _contract = Contract(_noDeploy: ())
            var _argsLoader = EndpointArgumentsLoader()
            let buffer = Buffer(topDecodeMulti: &_argsLoader)
            _contract.singleFunction(buffer: buffer)
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
        @Controller
        struct Contract {
            public func singleFunction(buffer: Buffer, number: BigUint) {
                
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction(buffer: Buffer, number: BigUint) {
                
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }
        
            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
                    public func singleFunction(buffer: Buffer, number: BigUint) {
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
            let _ = Contract()
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            var _contract = Contract(_noDeploy: ())
            var _argsLoader = EndpointArgumentsLoader()
            let buffer = Buffer(topDecodeMulti: &_argsLoader)
            let number = BigUint(topDecodeMulti: &_argsLoader)
            _contract.singleFunction(buffer: buffer, number: number)
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
        @Controller
        struct Contract {
            public func singleFunction() -> Buffer {
                return "Hello World!"
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction() -> Buffer {
                return "Hello World!"
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
                    public func singleFunction() -> Buffer {
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
            let _ = Contract()
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            var _contract = Contract(_noDeploy: ())

            let endpointOutput = _contract.singleFunction()

            var _result = Buffer()
            endpointOutput.topEncode(output: &_result)

            _result.finish()
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
    
    func testExpandSingleFunctionWithOneParamAndReturnStruct() throws {
        let source = """
        @Controller
        struct Contract {
            public func singleFunction(buffer: Buffer) -> BigUint {
                return BigUint(topDecode: buffer)
            }
        }
        """

        let expected = """
        struct Contract {
            public func singleFunction(buffer: Buffer) -> BigUint {
                return BigUint(topDecode: buffer)
            }
        
            init() {
            }

            init(_noDeploy: ()) {
            }

            #if !WASM
            public static func testable(_ _testableAddress: String) -> Testable {
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
                    public func singleFunction(buffer: Buffer) -> BigUint {
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
            let _ = Contract()
        }

        @_expose(wasm, "singleFunction")
        @_cdecl("singleFunction") func __macro_local_14singleFunctionfMu_() {
            var _contract = Contract(_noDeploy: ())
            var _argsLoader = EndpointArgumentsLoader()
            let buffer = Buffer(topDecodeMulti: &_argsLoader)
            let endpointOutput = _contract.singleFunction(buffer: buffer)

            var _result = Buffer()
            endpointOutput.topEncode(output: &_result)

            _result.finish()
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
        @Controller
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
                Testable(_testableAddress)
            }

            public struct Testable {
                let address: String
                init(_ _testableAddress: String) {
                    self.address = _testableAddress
                    runTestCall(
                        contractAddress: self.address,
                        endpointName: "init",
                        hexEncodedArgs: []
                    ) {
                        let _ = Contract()
                    }
                }
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
            let _ = Contract()
        }

        @_expose(wasm, "firstFunction")
        @_cdecl("firstFunction") func __macro_local_13firstFunctionfMu_() {
            var _contract = Contract(_noDeploy: ())

            _contract.firstFunction()
        }

        @_expose(wasm, "secondFunction")
        @_cdecl("secondFunction") func __macro_local_14secondFunctionfMu_() {
            var _contract = Contract(_noDeploy: ())

            _contract.secondFunction()
        }
        """

        assertMacroExpansion(
            source,
            expandedSource: expected,
            macros: testMacros
        )
    }
     */
}
