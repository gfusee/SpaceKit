import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import CodableMacro

let testMacros: [String: Macro.Type] = [
    "Codable": Codable.self,
]

final class CodableMacroStructTests: XCTestCase {
    /*
    func testExpandClassShouldFail() throws {
        let source = """
        @Codable
        class TokenPayment {}
        """
        
        let expected = """
        class TokenPayment {}
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Codable can only be applied to a structure or an enum.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandStructWithInitShouldFail() throws {
        let source = """
        @Codable
        struct TokenPayment {
            init() {}
        }
        """
        
        let expected = """
        struct TokenPayment {
            init() {}
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "A structure annotated with @Codable should not have an initializer.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandStructWithoutAnyFieldShouldFail() throws {
        let source = """
        @Codable
        struct TokenPayment {
        }
        """
        
        let expected = """
        struct TokenPayment {
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "A structure annotated with @Codable should have at least one field.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandStructWithOneField() throws {
        let source = """
        @Codable
        struct TokenPayment {
            let tokenIdentifier: TokenIdentifier
        }
        """
        
        let expected = """
        struct TokenPayment {
            let tokenIdentifier: TokenIdentifier
        }
        
        extension TokenPayment: TopEncode {
            @inline(__always)
    public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
                var nestedEncoded = MXBuffer()
                self.depEncode(dest: &nestedEncoded)
                nestedEncoded.topEncode(output: &output)
            }
        }
        
        extension TokenPayment: NestedEncode {
            func depEncode<O: NestedEncodeOutput>(dest: inout O) {
                self.tokenIdentifier.depEncode(dest: &dest)
            }
        }

        extension TokenPayment: TopDecode {
            @inline(__always)
    public static func topDecode(input: MXBuffer) -> TokenPayment {
                var input = BufferNestedDecodeInput(buffer: input)
        
                defer {
                    guard !input.canDecodeMore() else {
                        fatalError()
                    }
                }
        
                return TokenPayment(depDecode: &input)
            }
        }

        extension TokenPayment: TopDecodeMulti {
        }
        
        extension TokenPayment: NestedDecode {
            static func depDecode<I: NestedDecodeInput>(input: inout I) -> TokenPayment {
                return TokenPayment(
                    tokenIdentifier : TokenIdentifier(depDecode: &input)
                )
            }
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [],
            macros: testMacros
        )
    }
    
    func testExpandStructWithTwoFields() throws {
        let source = """
        @Codable
        struct TokenPayment {
            let tokenIdentifier: TokenIdentifier
            let nonce: UInt64
        }
        """
        
        let expected = """
        struct TokenPayment {
            let tokenIdentifier: TokenIdentifier
            let nonce: UInt64
        }
        
        extension TokenPayment: TopEncode {
            @inline(__always)
    public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
                var nestedEncoded = MXBuffer()
                self.depEncode(dest: &nestedEncoded)
                nestedEncoded.topEncode(output: &output)
            }
        }
        
        extension TokenPayment: NestedEncode {
            func depEncode<O: NestedEncodeOutput>(dest: inout O) {
                self.tokenIdentifier.depEncode(dest: &dest)
                self.nonce.depEncode(dest: &dest)
            }
        }

        extension TokenPayment: TopDecode {
            @inline(__always)
    public static func topDecode(input: MXBuffer) -> TokenPayment {
                var input = BufferNestedDecodeInput(buffer: input)
        
                defer {
                    guard !input.canDecodeMore() else {
                        fatalError()
                    }
                }
        
                return TokenPayment(depDecode: &input)
            }
        }

        extension TokenPayment: TopDecodeMulti {
        }
        
        extension TokenPayment: NestedDecode {
            static func depDecode<I: NestedDecodeInput>(input: inout I) -> TokenPayment {
                return TokenPayment(
                    tokenIdentifier : TokenIdentifier(depDecode: &input),
                    nonce : UInt64(depDecode: &input)
                )
            }
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [],
            macros: testMacros
        )
    }
     */
}
