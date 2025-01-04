import SpaceKit
import SpaceKitTesting

@Controller public struct TokenIssuanceController {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: Buffer
    @Storage(key: "lastErrorMessage") var lastErrorMessage: Buffer
    
    public func issueToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        initialSupply: BigUint,
        properties: FungibleTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                initialSupply: initialSupply,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    @Callback public mutating func issueCallback(caller: Address) {
        let asyncResult: AsyncCallResult<Buffer> = Message.asyncCallResult()
        
        switch asyncResult {
        case .success(let tokenIdentifier):
            self.issuedTokenIdentifier = tokenIdentifier
        case .error(let asyncCallError):
            self.lastErrorMessage = asyncCallError.errorMessage
        }
    }
}

final class TokenIssuanceTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "user"
            ),
            WorldAccount(
                address: "contract",
                controllers: [
                    TokenIssuanceController.self
                ]
            )
        ]
    }
    
    func testIssueFungibleToken() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(TokenIssuanceController.self, for: "contract")!
        
        try controller.issueToken(
            tokenDisplayName: "TestToken",
            tokenTicker: "TEST",
            initialSupply: 100,
            properties: FungibleTokenProperties(
                numDecimals: 18,
                canFreeze: false,
                canWipe: false,
                canPause: false,
                canMint: false,
                canBurn: false,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: false
            )
        )
        
        let userTestBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "TEST-000000",
                nonce: 0
            )
        
        XCTAssertEqual(userTestBalance, 100)
    }
}
