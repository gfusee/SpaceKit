import SpaceKitTesting
import Flip

private let PLAYER_ADDRESS = "player"
private let PLAYER_TWO_ADDRESS = "player2"
private let PLAYER_THREE_ADDRESS = "player3"
private let PLAYER_FOUR_ADDRESS = "player4"
private let PLAYER_FIVE_ADDRESS = "player5"
private let PLAYER_SIX_ADDRESS = "player6"
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
                address: PLAYER_TWO_ADDRESS,
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
                address: PLAYER_THREE_ADDRESS,
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
                address: PLAYER_FOUR_ADDRESS,
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
                address: PLAYER_FIVE_ADDRESS,
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
                address: PLAYER_SIX_ADDRESS,
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
    
    func testBountySingleWinEgld() throws {
        try self.initContract()
        try self.setupEgld()
        try self.flipSingleEgld(amount: 100_000)
        
        let blockRandomSeed = Array(repeating: UInt8(0), count: 47) + [6]
        
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
        
        XCTAssertEqual(flipContractBalance, 99_906_000)
        XCTAssertEqual(ownerBalance, 5_000)
        XCTAssertEqual(playerBalance, 100_088_000)
        XCTAssertEqual(bountyBalance, 1_000)
        XCTAssertEqual(tokenReserve, 99_906_000)
    }
    
    func testBountySingleWinUsdc() throws {
        try self.initContract()
        try self.setupUsdc()
        try self.flipSingleUsdc(amount: 100_000)
        
        let blockRandomSeed = Array(repeating: UInt8(0), count: 47) + [6]
        
        self.setBlockInfos(
            nonce: 1,
            randomSeed: Data(blockRandomSeed)
        )
        
        try self.bounty()
        
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        let flipContractBalance = self.getAccount(address: CONTRACT_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        let playerBalance = self.getAccount(address: PLAYER_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        let bountyBalance = self.getAccount(address: BOUNTY_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        
        let tokenReserve = try storageController.getTokenReserve(
            tokenIdentifier: USDC_TOKEN_IDENTIFIER,
            tokenNonce: 0
        )
        
        XCTAssertEqual(flipContractBalance, 99_906_000)
        XCTAssertEqual(ownerBalance, 5_000)
        XCTAssertEqual(playerBalance, 100_088_000)
        XCTAssertEqual(bountyBalance, 1_000)
        XCTAssertEqual(tokenReserve, 99_906_000)
    }

    func testBountySingleLoseEgld() throws {
        try self.initContract()
        try self.setupEgld()
        try self.flipSingleEgld(amount: 100_000)
        
        let blockRandomSeed = Array(repeating: UInt8(0), count: 47) + [4]
        
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
    
    func testBountySingleLoseUsdc() throws {
        try self.initContract()
        try self.setupUsdc()
        try self.flipSingleUsdc(amount: 100_000)
        
        let blockRandomSeed = Array(repeating: UInt8(0), count: 47) + [4]
        
        self.setBlockInfos(
            nonce: 1,
            randomSeed: Data(blockRandomSeed)
        )
        
        try self.bounty()
        
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        let flipContractBalance = self.getAccount(address: CONTRACT_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        let playerBalance = self.getAccount(address: PLAYER_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        let bountyBalance = self.getAccount(address: BOUNTY_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        
        let tokenReserve = try storageController.getTokenReserve(
            tokenIdentifier: USDC_TOKEN_IDENTIFIER,
            tokenNonce: 0
        )
        
        XCTAssertEqual(flipContractBalance, 100_094_000)
        XCTAssertEqual(ownerBalance, 5_000)
        XCTAssertEqual(playerBalance, 99_900_000)
        XCTAssertEqual(bountyBalance, 1_000)
        XCTAssertEqual(tokenReserve, 100_094_000)
    }
    
    func testFlipAndBountyMultiple() throws {
        try self.initContract()
        try self.setupEgld()
        
        try self.flipSingleEgld(
            amount: 100_000,
            address: PLAYER_ADDRESS
        )
        
        let blockRandomSeedNonce1 = Data(Array(repeating: UInt8(0), count: 47) + [6])
        
        self.setBlockInfos(
            nonce: 1,
            randomSeed: blockRandomSeedNonce1
        )
        
        try self.bounty()
        
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        do {
            let flipContractBalance = self.getAccount(address: CONTRACT_ADDRESS)!.balance
            let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!.balance
            let playerOneBalance = self.getAccount(address: PLAYER_ADDRESS)!.balance
            let bountyBalance = self.getAccount(address: BOUNTY_ADDRESS)!.balance
            let tokenReserve = try storageController.getTokenReserve(
                tokenIdentifier: .egld,
                tokenNonce: 0
            )
            
            XCTAssertEqual(flipContractBalance, 99_906_000)
            XCTAssertEqual(ownerBalance, 5_000)
            XCTAssertEqual(playerOneBalance, 100_088_000)
            XCTAssertEqual(bountyBalance, 1_000)
            XCTAssertEqual(tokenReserve, 99_906_000)
        }
        
        try self.flipSingleEgld(
            amount: 100_000,
            address: PLAYER_TWO_ADDRESS
        )
        
        let blockRandomSeedNonce2 = Data(Array(repeating: UInt8(0), count: 47) + [5])
        
        self.setBlockInfos(
            nonce: 2,
            randomSeed: blockRandomSeedNonce2
        )
        
        try self.bounty()
        
        try self.flipSingleEgld(
            amount: 100_000,
            address: PLAYER_THREE_ADDRESS
        )
        
        do {
            let flipContractBalance = self.getAccount(address: CONTRACT_ADDRESS)!.balance
            let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!.balance
            let playerOneBalance = self.getAccount(address: PLAYER_ADDRESS)!.balance
            let playerTwoBalance = self.getAccount(address: PLAYER_TWO_ADDRESS)!.balance
            let bountyBalance = self.getAccount(address: BOUNTY_ADDRESS)!.balance
            let tokenReserve = try storageController.getTokenReserve(
                tokenIdentifier: .egld,
                tokenNonce: 0
            )
            
            XCTAssertEqual(flipContractBalance, 100_095_000)
            XCTAssertEqual(ownerBalance, 15_000)
            XCTAssertEqual(playerOneBalance, 100_088_000)
            XCTAssertEqual(playerTwoBalance, 99_900_000)
            XCTAssertEqual(bountyBalance, 2_000)
            XCTAssertEqual(tokenReserve, 99_906_000)
        }
        
        self.setBlockInfos(
            nonce: 3
        )
        
        try self.flipSingleEgld(
            amount: 100_000,
            address: PLAYER_FOUR_ADDRESS
        )
        
        self.setBlockInfos(
            nonce: 4
        )
        
        try self.flipSingleEgld(
            amount: 100_000,
            address: PLAYER_FIVE_ADDRESS
        )
        
        try self.flipSingleEgld(
            amount: 100_000,
            address: PLAYER_SIX_ADDRESS
        )
        
        let blockRandomSeedNonce5 = Data(Array(repeating: UInt8(0), count: 47) + [4])
        
        self.setBlockInfos(
            nonce: 5,
            randomSeed: blockRandomSeedNonce5
        )
        
        try self.bounty()
        
        do {
            let flipContractBalance = self.getAccount(address: CONTRACT_ADDRESS)!.balance
            let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!.balance
            let playerOneBalance = self.getAccount(address: PLAYER_ADDRESS)!.balance
            let playerTwoBalance = self.getAccount(address: PLAYER_TWO_ADDRESS)!.balance
            let playerThreeBalance = self.getAccount(address: PLAYER_THREE_ADDRESS)!.balance
            let playerFourBalance = self.getAccount(address: PLAYER_FOUR_ADDRESS)!.balance
            let playerFiveBalance = self.getAccount(address: PLAYER_FIVE_ADDRESS)!.balance
            let playerSixBalance = self.getAccount(address: PLAYER_SIX_ADDRESS)!.balance
            let bountyBalance = self.getAccount(address: BOUNTY_ADDRESS)!.balance
            let tokenReserve = try storageController.getTokenReserve(
                tokenIdentifier: .egld,
                tokenNonce: 0
            )
            
            XCTAssertEqual(flipContractBalance, 100_188_000)
            XCTAssertEqual(ownerBalance, 30_000)
            XCTAssertEqual(playerOneBalance, 100_088_000)
            XCTAssertEqual(playerTwoBalance, 99_900_000)
            XCTAssertEqual(playerThreeBalance, 99_900_000)
            XCTAssertEqual(playerFourBalance, 99_900_000)
            XCTAssertEqual(playerFiveBalance, 100_088_000)
            XCTAssertEqual(playerSixBalance, 99_900_000)
            XCTAssertEqual(bountyBalance, 6_000)
            XCTAssertEqual(tokenReserve, 100_188_000)
        }
    }
    
    func testFlipTooHighBetAbsoluteValue() throws {
        try self.initContract()
        try self.setupEgld()
        
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
        try adminController.setMaximumBet(
            tokenIdentifier: .egld,
            nonce: 0,
            amount: 1_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        try adminController.setMaximumBetPercent(
            tokenIdentifier: .egld,
            nonce: 0,
            percent: 100_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        let gameController = self.instantiateController(GameController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try gameController.flip(
                transactionInput: ContractCallTransactionInput(
                    callerAddress: PLAYER_ADDRESS,
                    egldValue: 1_500
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Bet is too high. Maximum allowed bet: 1000"))
        }
    }
    
    func testFlipTooHighBetPercent() throws {
        try self.initContract()
        try self.setupEgld()
        
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
            percent: 10,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        let gameController = self.instantiateController(GameController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try gameController.flip(
                transactionInput: ContractCallTransactionInput(
                    callerAddress: PLAYER_ADDRESS,
                    egldValue: 150_000
                )
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Bet is too high. Maximum allowed bet: 100000"))
        }
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
        
        try adminController.withdrawReserve(
            tokenIdentifier: .egld,
            nonce: 0,
            amount: 10_000_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
            )
        )
        
        let tokenReserve = try storageController.getTokenReserve(
            tokenIdentifier: .egld,
            tokenNonce: 0
        )
        let contractBalance = self.getAccount(address: CONTRACT_ADDRESS)!.balance
        let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!.balance
        
        XCTAssertEqual(tokenReserve, 90_000_000)
        XCTAssertEqual(contractBalance, 90_000_000)
        XCTAssertEqual(ownerBalance, 10_000_000)
    }
    
    func testWithdrawUsdcReserve() throws {
        try self.initContract()
        try self.setupUsdc()
        
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        let storageController = self.instantiateController(StorageController.self, for: CONTRACT_ADDRESS)!
        
        try adminController.withdrawReserve(
            tokenIdentifier: USDC_TOKEN_IDENTIFIER,
            nonce: 0,
            amount: 10_000_000,
            transactionInput: ContractCallTransactionInput(
                callerAddress: OWNER_ADDRESS
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
        let ownerBalance = self.getAccount(address: OWNER_ADDRESS)!
            .getEsdtBalance(
                tokenIdentifier: USDC_TOKEN_IDENTIFIER_STRING,
                nonce: 0
            )
        
        XCTAssertEqual(tokenReserve, 90_000_000)
        XCTAssertEqual(contractBalance, 90_000_000)
        XCTAssertEqual(ownerBalance, 10_000_000)
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
    
    func testIncreaseReserveNotOwner() throws {
        try self.initContract()
        let adminController = self.instantiateController(AdminController.self, for: CONTRACT_ADDRESS)!
        
        do {
            try adminController.increaseReserve()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, ONLY_OWNER_ERROR)
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
    
    private func flipSingleEgld(
        amount: BigUint,
        address: String = PLAYER_ADDRESS
    ) throws {
        let gameController = self.instantiateController(
            GameController.self,
            for: CONTRACT_ADDRESS
        )!
        
        try gameController.flip(
            transactionInput: ContractCallTransactionInput(
                callerAddress: address,
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
