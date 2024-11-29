import SpaceKit
import XCTest

@Proxy enum ExecuteOnDestContextTestsProxy {
    case receiveTokens
}

@Contract struct ExecuteOnDestContextTestsContract {
    @Storage(key: "lastReceivedTokens") var lastReceivedTokens: Vector<TokenPayment>
    
    public mutating func receiveTokens() {
        self.lastReceivedTokens = Message.allEsdtTransfers
    }
    
    public func sendTokens(
        receiver: Address
    ) {
        ExecuteOnDestContextTestsProxy
            .receiveTokens
            .callAndIgnoreResult(
                receiver: receiver,
                esdtTransfers: Message.allEsdtTransfers
            )
    }
    
    public func getLastReceivedTokens() -> Vector<TokenPayment> {
        self.lastReceivedTokens
    }
}


final class ExecuteOnDestContextTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "owner",
                esdtBalances: [
                    "WEGLD-abcdef": [
                        EsdtBalance(nonce: 0, balance: 1000)
                    ],
                    "SFT-abcdef": [
                        EsdtBalance(nonce: 2, balance: 1000),
                        EsdtBalance(nonce: 10, balance: 1000)
                    ],
                    "OTHER-abcdef": [
                        EsdtBalance(nonce: 3, balance: 1000),
                    ]
                ]
            ),
            WorldAccount(address: "sender"),
            WorldAccount(address: "receiver")
        ]
    }
    
    func testSendNoToken() throws {
        let sender = try ExecuteOnDestContextTestsContract.Testable("sender")
        let receiver = try ExecuteOnDestContextTestsContract.Testable("receiver")
        
        let esdtValue: Vector<TokenPayment> = Vector()
        
        try sender.sendTokens(
            receiver: "receiver",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "owner",
                esdtValue: esdtValue
            )
        )
        
        let receiverLastReceivedTokens = try receiver.getLastReceivedTokens()
        let expectedReceiverLastReceivedTokens: Vector<TokenPayment> = Vector()
        
        XCTAssertEqual(receiverLastReceivedTokens, expectedReceiverLastReceivedTokens)
    }

    func testSendOneFungibleToken() throws {
        let sender = try ExecuteOnDestContextTestsContract.Testable("sender")
        let receiver = try ExecuteOnDestContextTestsContract.Testable("receiver")
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment.new(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0,
                amount: 100
            )
        )
        
        try sender.sendTokens(
            receiver: "receiver",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "owner",
                esdtValue: esdtValue
            )
        )
        
        let receiverLastReceivedTokens = try receiver.getLastReceivedTokens()
        let ownerWEGLDBalance = self.getAccount(address: "owner")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let senderWEGLDBalance = self.getAccount(address: "sender")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let receiverWEGLDBalance = self.getAccount(address: "receiver")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        
        var expectedReceiverLastReceivedTokens: Vector<TokenPayment> = Vector()
        let expectedOwnerWEGLDBalance: BigUint = 900
        let expectedSenderWEGLDBalance: BigUint = 0
        let expectedReceiverWEGLDBalance: BigUint = 100
        
        expectedReceiverLastReceivedTokens = expectedReceiverLastReceivedTokens.appended(
            TokenPayment.new(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0,
                amount: 100
            )
        )
        
        XCTAssertEqual(receiverLastReceivedTokens, expectedReceiverLastReceivedTokens)
        XCTAssertEqual(ownerWEGLDBalance, expectedOwnerWEGLDBalance)
        XCTAssertEqual(senderWEGLDBalance, expectedSenderWEGLDBalance)
        XCTAssertEqual(receiverWEGLDBalance, expectedReceiverWEGLDBalance)
    }
    
    func testSendOneNonFungibleToken() throws {
        let sender = try ExecuteOnDestContextTestsContract.Testable("sender")
        let receiver = try ExecuteOnDestContextTestsContract.Testable("receiver")
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment.new(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        try sender.sendTokens(
            receiver: "receiver",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "owner",
                esdtValue: esdtValue
            )
        )
        
        let receiverLastReceivedTokens = try receiver.getLastReceivedTokens()
        let ownerSFTBalance = self.getAccount(address: "owner")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let senderSFTBalance = self.getAccount(address: "sender")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let receiverSFTBalance = self.getAccount(address: "receiver")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        
        var expectedReceiverLastReceivedTokens: Vector<TokenPayment> = Vector()
        let expectedOwnerSFTBalance: BigUint = 900
        let expectedSenderSFTBalance: BigUint = 0
        let expectedReceiverSFTBalance: BigUint = 100
        
        expectedReceiverLastReceivedTokens = expectedReceiverLastReceivedTokens.appended(
            TokenPayment.new(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        XCTAssertEqual(receiverLastReceivedTokens, expectedReceiverLastReceivedTokens)
        XCTAssertEqual(ownerSFTBalance, expectedOwnerSFTBalance)
        XCTAssertEqual(senderSFTBalance, expectedSenderSFTBalance)
        XCTAssertEqual(receiverSFTBalance, expectedReceiverSFTBalance)
    }
    
    func testSendMultipleTokens() throws {
        let sender = try ExecuteOnDestContextTestsContract.Testable("sender")
        let receiver = try ExecuteOnDestContextTestsContract.Testable("receiver")
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment.new(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment.new(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10,
                amount: 150
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment.new(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3,
                amount: 200
            )
        )

        try sender.sendTokens(
            receiver: "receiver",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "owner",
                esdtValue: esdtValue
            )
        )
        
        let receiverLastReceivedTokens = try receiver.getLastReceivedTokens()
        let ownerSFT2Balance = self.getAccount(address: "owner")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let senderSFT2Balance = self.getAccount(address: "sender")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let receiverSFT2Balance = self.getAccount(address: "receiver")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        
        
        let ownerSFT10Balance = self.getAccount(address: "owner")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let senderSFT10Balance = self.getAccount(address: "sender")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let receiverSFT10Balance = self.getAccount(address: "receiver")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        
        let ownerOtherBalance = self.getAccount(address: "owner")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let senderOtherBalance = self.getAccount(address: "sender")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let receiverOtherBalance = self.getAccount(address: "receiver")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )

        var expectedReceiverLastReceivedTokens: Vector<TokenPayment> = Vector()
        
        let expectedOwnerSFT2Balance: BigUint = 900
        let expectedSenderSFT2Balance: BigUint = 0
        let expectedReceiverSFT2Balance: BigUint = 100
        
        let expectedOwnerSFT10Balance: BigUint = 850
        let expectedSenderSFT10Balance: BigUint = 0
        let expectedReceiverSFT10Balance: BigUint = 150
        
        let expectedOwnerOtherBalance: BigUint = 800
        let expectedSenderOtherBalance: BigUint = 0
        let expectedReceiverOtherBalance: BigUint = 200

        expectedReceiverLastReceivedTokens = expectedReceiverLastReceivedTokens.appended(
            TokenPayment.new(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        
        expectedReceiverLastReceivedTokens = expectedReceiverLastReceivedTokens.appended(
            TokenPayment.new(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10,
                amount: 150
            )
        )
        
        expectedReceiverLastReceivedTokens = expectedReceiverLastReceivedTokens.appended(
            TokenPayment.new(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3,
                amount: 200
            )
        )

        XCTAssertEqual(receiverLastReceivedTokens, expectedReceiverLastReceivedTokens)
        
        XCTAssertEqual(ownerSFT2Balance, expectedOwnerSFT2Balance)
        XCTAssertEqual(senderSFT2Balance, expectedSenderSFT2Balance)
        XCTAssertEqual(receiverSFT2Balance, expectedReceiverSFT2Balance)
        
        XCTAssertEqual(ownerSFT10Balance, expectedOwnerSFT10Balance)
        XCTAssertEqual(senderSFT10Balance, expectedSenderSFT10Balance)
        XCTAssertEqual(receiverSFT10Balance, expectedReceiverSFT10Balance)
        
        XCTAssertEqual(ownerOtherBalance, expectedOwnerOtherBalance)
        XCTAssertEqual(senderOtherBalance, expectedSenderOtherBalance)
        XCTAssertEqual(receiverOtherBalance, expectedReceiverOtherBalance)
    }
}
