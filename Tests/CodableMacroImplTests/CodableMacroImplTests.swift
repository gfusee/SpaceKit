import MultiversX
import XCTest

@Codable struct TokenPayment {
    let tokenIdentifier: MXBuffer
    let nonce: UInt64
    let amount: BigUint
}

final class CodableMacroImplTests: XCTestCase {
    
    func testTopEncodeForCustomStruct() throws {
        let tokenPayment = TokenPayment(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        var result = MXBuffer()
        tokenPayment.topEncode(output: &result)
        
        let expected = "0000000a5346542d616263646566000000000000000a0000000164"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
}
