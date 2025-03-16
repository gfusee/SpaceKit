import SpaceKitTesting
import Flip

private let PLAYER_ADDRESS = "player"
private let BOUNTY_ADDRESS = "bounty"
private let OWNER_ADDRESS = "owner"
private let CONTRACT_ADDRESS = "contract"
private let ONLY_OWNER_ERROR: TransactionError = .userError(message: "Endpoint can only be called by owner")
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
        try self.setupEgld()
    }
    
    func testFlipSingleEgld() throws {
        try self.initContract()
        try self.setupEgld()
        try self.flipSingleEgld(amount: 100_000)
        
        let storageController = self.instantiateController(
            StorageController.self,
            for: CONTRACT_ADDRESS
        )!
        
        let usdcTokenReserve = try storageController
            .getTokenReserve(
                tokenIdentifier: .egld,
                tokenNonce: 0
            )
        
        XCTAssertEqual(usdcTokenReserve, 99_906_000)
    }
    
    func testFlipSingleUsdc() throws {
        try self.initContract()
        try self.setupUsdc()
        try self.flipSingleUsdc(amount: 100_000)
        
        let storageController = self.instantiateController(
            StorageController.self,
            for: CONTRACT_ADDRESS
        )!
        
        let usdcTokenReserve = try storageController
            .getTokenReserve(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER,
                tokenNonce: 0
            )
        
        XCTAssertEqual(usdcTokenReserve, 99_906_000)
    }
    
    func testBountyTooEarly() throws {
        try self.initContract()
        try self.setupEgld()
        try self.flipSingleEgld(amount: 100_000)
        
        let gameController = self.instantiateController(GameController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try gameController.bounty(
                transactionInput: ContractCallTransactionInput(
                    callerAddress: BOUNTY_ADDRESS
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "No flip can be bounty."))
        }
    }
    
    func testBountySingleLoseEgld() throws {
        try self.initContract()
        try self.setupEgld()
        try self.flipSingleEgld(amount: 100_000)
        
        let blockRandomSeed = Array(repeating: UInt8(0), count: 47) + [3]
        
        self.setBlockInfos(
            nonce: 1,
            randomSeed: Data(blockRandomSeed)
        )
        
        try self.bounty()
        
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        let flipContractBalance = self.getAccount(address: CONTRACT_ADDRESS)!.balance
        let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!.balance
        let playerBalance = self.getAccount(address: PLAYER_ADDRESS)!.balance
        let bountyBalance = self.getAccount(address: BOUNTY_ADDRESS)!.balance
        
        let tokenReserve = try storageController.getTokenReserve(
            tokenIdentifier: .egld,
            tokenNonce: 0
        )
        
        XCTAssertEqual(flipContractBalance, 100_094_000)
        XCTAssertEqual(ownerBalance, 5_000)
        XCTAssertEqual(playerBalance, 99_900_000)
        XCTAssertEqual(bountyBalance, 1_000)
        
        XCTAssertEqual(tokenReserve, 100_094_000)
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
            XCTAssertEqual(error, ONLY_OWNER_ERROR)
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
            XCTAssertEqual(error, ONLY_OWNER_ERROR)
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
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
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
            percent: 10_000_000,
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
            percent: 10_000_000,
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
    
    private func flipSingleEgld(amount: BigUint) throws {
        let gameController = self.instantiateController(
            GameController.self,
            for: CONTRACT_ADDRESS
        )!
        
        try gameController.flip(
            transactionInput: ContractCallTransactionInput(
                callerAddress: PLAYER_ADDRESS,
                egldValue: 100_000
            )
        )
    }
    
    private func flipSingleUsdc(amount: BigUint) throws {
        let gameController = self.instantiateController(
            GameController.self,
            for: CONTRACT_ADDRESS
        )!
        
        try gameController.flip(
            transactionInput: ContractCallTransactionInput(
                callerAddress: PLAYER_ADDRESS,
                esdtValue: [
                    TokenPayment(
                        tokenIdentifier: USDC_TOKEN_IDENTIFIER,
                        nonce: 0,
                        amount: amount
                    )
                ]
            )
        )
    }
    
    private func bounty() throws {
        let gameController = self.instantiateController(
            GameController.self,
            for: CONTRACT_ADDRESS
        )!
        
        try gameController.bounty(
            transactionInput: ContractCallTransactionInput(
                callerAddress: BOUNTY_ADDRESS
            )
        )
    }
}
