import XCTest
import MultiversX

@Contract struct BlockchainContract {
    
    public func getSelfAddress() -> Address {
        return Blockchain.getSCAddress()
    }
    
}

final class BlockchainTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "adder")
        ]
    }
    
    func testGetSCAddress() throws {
        let contract = BlockchainContract.testable("adder")
        
        let contractAddress = contract.getSelfAddress()
        var encodedAddress = MXBuffer()
        contractAddress.topEncode(output: &encodedAddress)
        
        XCTAssertEqual(encodedAddress.hexDescription, "0000000000000000000061646465725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f")
    }
    
}
