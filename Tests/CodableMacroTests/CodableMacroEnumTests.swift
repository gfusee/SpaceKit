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
                    message: "An enumeration annotated with @Codable should neither inherit unknown protocols nor have raw values.\n\nHowever, you can inherit the following protocol: Equatable.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
    
    func testExpandNamedAssociatedValueEnumShouldFail() throws {
        let source = """
        @Codable
        enum PaymentType {
            case egld(value: BigUint)
        }
        """
        
        let expected = """
        enum PaymentType {
            case egld(value: BigUint)
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "Associated values in an enumeration annotated with @Codable should not be named. For example, `case myCase(String)` is valid while `case myCase(value: String)` is not.",
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
        enum PaymentType {
            \(cases)
        }
        """
        
        let expected = """
        enum PaymentType {
            \(cases)
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "An enumeration annotated with @Codable should have at maximum 255 cases.",
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
        enum PaymentType {
            case firstCase
            case \(cases)
        }
        """
        
        let expected = """
        enum PaymentType {
            case firstCase
            case \(cases)
        }
        """
        
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [
                DiagnosticSpec(
                    message: "An enumeration annotated with @Codable should have at maximum 255 cases.",
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
        enum PaymentType: Equatable {
            case egld
            case esdt, multiEsdts
        }
        """
        
        let expected = """
        enum PaymentType: Equatable {
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

                defer {
                    guard !input.canDecodeMore() else {
                        fatalError()
                    }
                }

                return PaymentType.depDecode(input: &input)
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
                    default:
                    fatalError()
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
    
    func testExpandEnumWithAssociatedValues() throws {
        let source = """
        @Codable
        enum SinglePayment: Equatable {
            case egld(BigUint)
            case esdt(MXBuffer, UInt64, BigUint), none
        }
        """
        
        let expected = """
        enum SinglePayment: Equatable {
            case egld(BigUint)
            case esdt(MXBuffer, UInt64, BigUint), none
        }
        
        extension SinglePayment: TopEncode {
            public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
                var nestedEncoded = MXBuffer()
                self.depEncode(dest: &nestedEncoded)
                nestedEncoded.topEncode(output: &output)
            }
        }
        
        extension SinglePayment: NestedEncode {
            func depEncode<O: NestedEncodeOutput>(dest: inout O) {
                switch self {
                    case .egld(let value0):
                    UInt8(0).depEncode(dest: &dest)
                    value0.depEncode(dest: &dest)
                case .esdt(let value0, let value1, let value2):
                    UInt8(1).depEncode(dest: &dest)
                    value0.depEncode(dest: &dest)
                    value1.depEncode(dest: &dest)
                    value2.depEncode(dest: &dest)
                case .none:
                    UInt8(2).depEncode(dest: &dest)
                }
            }
        }
        
        extension SinglePayment: TopDecode {
            public static func topDecode(input: MXBuffer) -> SinglePayment {
                var input = BufferNestedDecodeInput(buffer: input)

                defer {
                    guard !input.canDecodeMore() else {
                        fatalError()
                    }
                }

                return SinglePayment.depDecode(input: &input)
            }
        }
        
        extension SinglePayment: TopDecodeMulti {
        }
        
        extension SinglePayment: NestedDecode {
            static func depDecode<I: NestedDecodeInput>(input: inout I) -> SinglePayment {
                let _discriminant = UInt8.depDecode(input: &input)

                switch _discriminant {
                    case 0:
                    return .egld(
                        BigUint.depDecode(input: &input)
                    )
                case 1:
                    return .esdt(
                        MXBuffer.depDecode(input: &input),
                        UInt64.depDecode(input: &input),
                        BigUint.depDecode(input: &input)
                    )
                case 2:
                    return .none
                    default:
                    fatalError()
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
