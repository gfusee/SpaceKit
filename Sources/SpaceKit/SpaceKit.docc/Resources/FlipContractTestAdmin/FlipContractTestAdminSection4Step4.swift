import SpaceKitTesting
import Flip

private let PLAYER_ADDRESS = "player"
private let BOUNTY_ADDRESS = "bounty"
private let OWNER_ADDRESS = "owner"
private let CONTRACT_ADDRESS = "contract"
private let USDC_TOKEN_IDENTIFIER_STRING = "USDC-abcdef"
private var USDC_TOKEN_IDENTIFIER: TokenIdentifier {
    "\(USDC_TOKEN_IDENTIFIER_STRING)"
}

final class FlipTests: ContractTestCase {
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: PLAYER_ADDRESS,
                balance: 100_000_000,
                esdtBalances: [
                    USDC_TOKEN_IDENTIFIER_STRING: [
                        EsdtBalance(
                            nonce: 0,
                            balance: 100_000_000
                        )
                    ]
                ]
            ),
            WorldAccount(
                address: BOUNTY_ADDRESS,
                balance: 0
            ),
            WorldAccount(
                address: OWNER_ADDRESS,
                balance: 100_000_000,
                esdtBalances: [
                    USDC_TOKEN_IDENTIFIER_STRING: [
                        EsdtBalance(
                            nonce: 0,
                            balance: 100_000_000
                        )
                    ]
                ]
            ),
            WorldAccount(
                address: CONTRACT_ADDRESS,
                balance: 0,
                controllers: [
                    AdminController.self,
                    GameController.self,
                    StorageController.self
                ]
            )
        ]
    }
    
    func testInitEgld() throws {
        try self.initContract()
        try self.setupEgld()
    }
    
    func testInitUsdc() throws {
        try self.initContract()
        try self.setupUsdc()
    }
    
    func testSetMaximumBet() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        try adminController.setMaximumBet(
            tokenIdentifier: .egld,
            nonce: 0,
            amount: 100,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        let maximumBet = try storageController.getMaximumBet(
            tokenIdentifier: .egld,
            tokenNonce: 0
        )
        
        XCTAssertEqual(maximumBet, 100)
    }
    
    func testSetMaximumBetPercent() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        try adminController.setMaximumBetPercent(
            tokenIdentifier: .egld,
            nonce: 0,
            percent: 100,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        let maximumBetPercent = try storageController.getMaximumBetPercent(
            tokenIdentifier: .egld,
            tokenNonce: 0
        )
        
        XCTAssertEqual(maximumBetPercent, 100)
    }
    
    func testIncreaseEgldReserve() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        try adminController.increaseReserve(
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS,
                egldValue: 1_000
            )
        )
        
        let tokenReserve = try storageController.getTokenReserve(
            tokenIdentifier: .egld,
            tokenNonce: 0
        )
        let contractBalance = self.getAccount(address: CONTRACT_ADDRESS)!.balance
        
        XCTAssertEqual(tokenReserve, 1_000)
        XCTAssertEqual(contractBalance, 1_000)
    }
    
    func testIncreaseUsdcReserve() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        try adminController.increaseReserve(
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS,
                esdtValue: [
                    TokenPayment(
                        tokenIdentifier: USDC_TOKEN_IDENTIFIER,
                        nonce: 0,
                        amount: 1_000
                    )
                ]
            )
        )
        
        let tokenReserve = try storageController.getTokenReserve(
            tokenIdentifier: USDC_TOKEN_IDENTIFIER,
            tokenNonce: 0
        )
        let contractBalance = self.getAccount(address: CONTRACT_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        
        XCTAssertEqual(tokenReserve, 1_000)
        XCTAssertEqual(contractBalance, 1_000)
    }
    
    func testWithdrawEgldReserve() throws {
        try self.initContract()
        try self.setupEgld()
        
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
    }
    
    func testSetMaximumBetNotOwner() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try adminController.setMaximumBet(
                tokenIdentifier: .egld,
                nonce: 0,
                amount: 10_000_000
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Endpoint can only be called by owner"))
        }
    }
    
    func testSetMaximumBetPercentNotOwner() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try adminController.setMaximumBetPercent(
                tokenIdentifier: .egld,
                nonce: 0,
                percent: 10_000_000
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Endpoint can only be called by owner"))
        }
    }
    
    func testIncreaseReserveNotOwner() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try adminController.increaseReserve()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Endpoint can only be called by owner"))
        }
    }
    
    func testWithdrawReserveNotOwner() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try adminController.withdrawReserve(
                tokenIdentifier: .egld,
                nonce: 0,
                amount: 100
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Endpoint can only be called by owner"))
        }
    }
    
    private func initContract() throws {
        try self.deployContract(
            at: CONTRACT_ADDRESS,
            arguments: [
               500,
               100,
               1
            ],
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
    }
    
    private func setupEgld() throws {
        let adminController = self.instantiateController(
            AdminController.self,
            for: CONTRACT_ADDRESS
        )!
        
        try adminController.setMaximumBet(
            tokenIdentifier: .egld,
            nonce: 0,
            amount: 100_000_000_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        try adminController.setMaximumBetPercent(
            tokenIdentifier: .egld,
            nonce: 0,
            percent: 1_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        try adminController.increaseReserve(
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS,
                egldValue: 100_000_000
            )
        )
    }
    
    private func setupUsdc() throws {
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
        try adminController.setMaximumBet(
            tokenIdentifier: USDC_TOKEN_IDENTIFIER,
            nonce: 0,
            amount: 100_000_000_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        try adminController.setMaximumBetPercent(
            tokenIdentifier: USDC_TOKEN_IDENTIFIER,
            nonce: 0,
            percent: 1_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        try adminController.increaseReserve(
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS,
                esdtValue: [
                    TokenPayment(
                        tokenIdentifier: USDC_TOKEN_IDENTIFIER,
                        nonce: 0,
                        amount: 100_000_000
                    )
                ]
            )
        )
    }
}
