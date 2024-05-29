import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import CodableMacro

final class CodableMacroEnumTests: XCTestCase {
    
    func testExpandEmptyEnumShouldFail() throws {
        let source = """
        @Codable
        enum PaymentType {}
        """
        
        let expected = """
        enum PaymentType {}
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "An enumeration annotated with @Codable should have at least one case.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandRawValueEnumShouldFail() throws {
        let source = """
        @Codable
        enum PaymentType: Int {
            case egld = 0
        }
        """
        
        let expected = """
        enum PaymentType: Int {
            case egld = 0
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "An enumeration annotated with @Codable should neither inherit any protocol nor have raw values.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandEnumWithTooManyCasesShouldFail() throws {
        let casesList: [String] = (0...256).map({ "case caseNumber\($0)" })
        let cases = casesList.joined(separator: "\n")
        
        let source = """
        @Codable
        enum PaymentType: Int {
            \(cases)
        }
        """
        
        let expected = """
        enum PaymentType: Int {
            \(cases)
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "An enumeration annotated with @Codable should neither inherit any protocol nor have raw values.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandEnumWithTooManyCasesInOneCaseShouldFail() throws {
        let casesList: [String] = (0...255).map({ "caseNumber\($0)" })
        let cases = casesList.joined(separator: ", ")
        
        let source = """
        @Codable
        enum PaymentType: Int {
            case firstCase
            case \(cases)
        }
        """
        
        let expected = """
        enum PaymentType: Int {
            case firstCase
            case \(cases)
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "An enumeration annotated with @Codable should neither inherit any protocol nor have raw values.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandEnumNoAssociatedValue() throws {
        let source = """
        @Codable
        enum PaymentType {
            case egld
            case esdt, multiEsdts
        }
        """
        
        let expected = """
        enum PaymentType {
            case egld
            case esdt, multiEsdts
        }
        
        extension PaymentType: TopEncode {
            public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
                var nestedEncoded = MXBuffer()
                self.depEncode(dest: &nestedEncoded)
                nestedEncoded.topEncode(output: &output)
            }
        }
        
        extension PaymentType: NestedEncode {
            func depEncode<O: NestedEncodeOutput>(dest: inout O) {
                switch self {
                    case .egld:
                    UInt8(0).depEncode(dest: &dest)
                case .esdt:
                    UInt8(1).depEncode(dest: &dest)
                case .multiEsdts:
                    UInt8(2).depEncode(dest: &dest)
                }
            }
        }
        
        extension PaymentType: TopDecode {
            public static func topDecode(input: MXBuffer) -> PaymentType {
                var input = BufferNestedDecodeInput(buffer: input)
                let _discriminant = UInt8.depDecode(input: &input)

                switch _discriminant {
                    case 0:
                    return .egld
                case 1:
                    return .esdt
                case 2:
                    return .multiEsdts
                }
            }
        }
        
        extension PaymentType: TopDecodeMulti {
        }
        
        extension PaymentType: NestedDecode {
            static func depDecode<I: NestedDecodeInput>(input: inout I) -> PaymentType {
                let _discriminant = UInt8.depDecode(input: &input)

                switch _discriminant {
                    case 0:
                    return .egld
                case 1:
                    return .esdt
                case 2:
                    return .multiEsdts
                }
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
    
}
