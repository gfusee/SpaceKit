import SpaceKit
import SpaceKitTesting

@Event(dataType: Buffer) public struct TestSingleIndexedFieldBufferDataEvent {
    let address: Address
}

@Event(dataType: BigUint) public struct TestSingleIndexedFieldBigUintDataEvent {
    let address: Address
}

@Event(dataType: Buffer) public struct TestMultipleIndexedFieldEvent {
    let address: Address
    let number: BigUint
    let buffer: Buffer
}

@Init func initialize() {
    let data: Buffer = "Hello World!"
    TestSingleIndexedFieldBufferDataEvent(address: Message.caller).emit(data: data)
    
    TestMultipleIndexedFieldEvent(
        address: Message.caller,
        number: 100,
        buffer: "Hello World!"
    ).emit(data: "")
}

@Controller public struct EventTestsController {
    public func emitNoEvent() {
        
    }
    
    public func emitSingleIndexedFieldEventNoData() {
        TestSingleIndexedFieldBufferDataEvent(address: Message.caller).emit(data: "")
    }
    
    public func emitSingleIndexedFieldEventWithBufferData() {
        let data: Buffer = "Hello World!"
        TestSingleIndexedFieldBufferDataEvent(address: Message.caller).emit(data: data)
    }
    
    public func emitSingleIndexedFieldEventWithBigUintData() {
        let data: BigUint = 100
        TestSingleIndexedFieldBigUintDataEvent(address: Message.caller).emit(data: data)
    }
    
    public func emitMultipleIndexedFieldEventNoData() {
        TestMultipleIndexedFieldEvent(
            address: Message.caller,
            number: 100,
            buffer: "Hello World!"
        ).emit(data: "")
    }
    
    public func emitMultipleEvents() {
        let data: Buffer = "Hello World!"
        TestSingleIndexedFieldBufferDataEvent(address: Message.caller).emit(data: data)
        
        TestMultipleIndexedFieldEvent(
            address: Message.caller,
            number: 100,
            buffer: "Hello World!"
        ).emit(data: "")
    }
    
    public func emitEventFromArgs(
        addressTopic: Address,
        numberTopic: BigUint,
        bufferTopic: Buffer,
        data: Buffer
    ) {
        TestMultipleIndexedFieldEvent(
            address: addressTopic,
            number: numberTopic,
            buffer: bufferTopic
        ).emit(data: data)
    }
}

final class EventTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    EventTestsController.self
                ]
            ),
            WorldAccount(address: "user")
        ]
    }
    
    func testNoEvent() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EventTestsController.self, for: "contract")!
        
        let transactionOutput = TransactionOutput()
        
        try controller.emitNoEvent(
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = []
        
        XCTAssertEqual(logs, expected)
    }
    
    func testSingleIndexedFieldEventNoData() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EventTestsController.self, for: "contract")!
        
        let transactionOutput = TransactionOutput()
        
        try controller.emitSingleIndexedFieldEventNoData(
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
                    "5465737453696e676c65496e64657865644669656c64427566666572446174614576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"
                ],
                data: ""
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testSingleIndexedFieldEventWithBufferData() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EventTestsController.self, for: "contract")!
        
        let transactionOutput = TransactionOutput()
        
        try controller.emitSingleIndexedFieldEventWithBufferData(
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
                    "5465737453696e676c65496e64657865644669656c64427566666572446174614576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"
                ],
                data: "48656c6c6f20576f726c6421"
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testSingleIndexedFieldEventWithBigUintData() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EventTestsController.self, for: "contract")!
        
        let transactionOutput = TransactionOutput()
        
        try controller.emitSingleIndexedFieldEventWithBigUintData(
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
                    "5465737453696e676c65496e64657865644669656c6442696755696e74446174614576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"
                ],
                data: "64"
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testMultipleIndexedFieldEventNoData() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EventTestsController.self, for: "contract")!
        
        let transactionOutput = TransactionOutput()
        
        try controller.emitMultipleIndexedFieldEventNoData(
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
                    "546573744d756c7469706c65496e64657865644669656c644576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f",
                    "64",
                    "48656c6c6f20576f726c6421"
                ],
                data: ""
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testMultipleEvents() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EventTestsController.self, for: "contract")!
        
        let transactionOutput = TransactionOutput()
        
        try controller.emitMultipleEvents(
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
                    "5465737453696e676c65496e64657865644669656c64427566666572446174614576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"
                ],
                data: "48656c6c6f20576f726c6421"
            ),
            TransactionOutputLog(
                topics: [
                    "546573744d756c7469706c65496e64657865644669656c644576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f",
                    "64",
                    "48656c6c6f20576f726c6421"
                ],
                data: ""
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testEventFromArgs() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(EventTestsController.self, for: "contract")!
        
        let transactionOutput = TransactionOutput()
        
        try controller.emitEventFromArgs(
            addressTopic: "user",
            numberTopic: 100,
            bufferTopic: "Hello World!",
            data: "Hello World!",
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
                    "546573744d756c7469706c65496e64657865644669656c644576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f",
                    "64",
                    "48656c6c6f20576f726c6421"
                ],
                data: "48656c6c6f20576f726c6421"
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testMultipleEventsInInit() throws {
        let transactionOutput = TransactionOutput()
        
        try self.deployContract(
            at: "contract",
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
                    "5465737453696e676c65496e64657865644669656c64427566666572446174614576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"
                ],
                data: "48656c6c6f20576f726c6421"
            ),
            TransactionOutputLog(
                topics: [
                    "546573744d756c7469706c65496e64657865644669656c644576656e74",
                    "00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f",
                    "64",
                    "48656c6c6f20576f726c6421"
                ],
                data: ""
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
}
