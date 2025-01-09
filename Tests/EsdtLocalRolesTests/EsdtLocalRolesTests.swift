import XCTest
import SpaceKit

final class EsdtLocalRolesTests: XCTestCase {
    func testAddRoles() throws {
        let roles1 = EsdtLocalRoles(canMint: true)
        let roles2 = EsdtLocalRoles()
        let roles3 = EsdtLocalRoles(canAddNftQuantity: true, canTransfer: true)
        
        var allRoles = EsdtLocalRoles()
        
        allRoles.addRoles(roles: roles1)
        allRoles.addRoles(roles: roles2)
        allRoles.addRoles(roles: roles3)
        
        XCTAssert(allRoles.contains(flag: .mint))
        XCTAssert(allRoles.contains(flag: .nftAddQuantity))
        XCTAssert(allRoles.contains(flag: .transfer))
        
        XCTAssert(!allRoles.contains(flag: .burn))
    }
}
