import SpaceKitTesting

final class TokenIdentifierTests: XCTestCase {
    func testIsValidESDTValid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN-abcdef"
        
        XCTAssertTrue(tokenIdentifier.isValid)
    }
    
    func testIsEGLD000000Valid() throws {
        let tokenIdentifier: TokenIdentifier = "EGLD-000000"
        
        XCTAssertTrue(tokenIdentifier.isValid)
    }
    
    func testIsTooLongRandomPartESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN-abcdefg"
        
        XCTAssertFalse(tokenIdentifier.isValid)
    }
    
    func testIsTooShortRandomPartESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN-a"
        
        XCTAssertFalse(tokenIdentifier.isValid)
    }
    
    func testIsNoRandomPartESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN"
        
        XCTAssertFalse(tokenIdentifier.isValid)
    }
}
