import XCTest
import SpaceKit

final class EsdtLocalRolesTests: XCTestCase {
    func testAddRoles() throws {
        let roles1 = EsdtLocalRoles(canMint: true)
        let roles2 = EsdtLocalRoles()
        let roles3 = EsdtLocalRoles(canAddNftQuantity: true, canModifyRoyalties: true)
        
        var allRoles = EsdtLocalRoles()
        
        allRoles.addRoles(roles: roles1)
        allRoles.addRoles(roles: roles2)
        allRoles.addRoles(roles: roles3)
        
        let expected = EsdtLocalRoles(
            canMint: true,
            canAddNftQuantity: true,
            canModifyRoyalties: true
        )
        
        XCTAssertEqual(allRoles, expected)
    }
}
