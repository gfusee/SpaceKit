import SpaceKitTesting

final class TokenIdentifierTests: XCTestCase {
    func testIsValidESDTValid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN-abcdef"
        
        XCTAssertTrue(tokenIdentifier.isValidESDT)
    }
    
    func testIsEGLD000000Valid() throws {
        let tokenIdentifier: TokenIdentifier = "EGLD-000000"
        
        XCTAssertTrue(tokenIdentifier.isValidESDT)
    }
    
    func testIsTooShortTickerESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "TO-abcdef"
        
        XCTAssertFalse(tokenIdentifier.isValidESDT)
    }
    
    func testIsTooLongTickerESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "AAAAAAAAAAA-abcdef"
        
        XCTAssertFalse(tokenIdentifier.isValidESDT)
    }
    
    func testIsTooLongRandomPartESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN-abcdefg"
        
        XCTAssertFalse(tokenIdentifier.isValidESDT)
    }
    
    func testIsTooShortRandomPartESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN-a"
        
        XCTAssertFalse(tokenIdentifier.isValidESDT)
    }
    
    func testIsNoRandomPartESDTInvalid() throws {
        let tokenIdentifier: TokenIdentifier = "TOKEN"
        
        XCTAssertFalse(tokenIdentifier.isValidESDT)
    }
}
