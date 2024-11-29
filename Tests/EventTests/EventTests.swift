import XCTest
import SpaceKit

@Event(dataType: Buffer) struct TestSingleIndexedFieldBufferDataEvent {
    let address: Address
}

@Event(dataType: BigUint) struct TestSingleIndexedFieldBigUintDataEvent {
    let address: Address
}

@Event(dataType: Buffer) struct TestMultipleIndexedFieldEvent {
    let address: Address
    let number: BigUint
    let buffer: Buffer
}

@Contract struct EventTestsContract {
    init() {
        let data: Buffer = "Hello World!"
        TestSingleIndexedFieldBufferDataEvent(address: Message.caller).emit(data: data)
        
        TestMultipleIndexedFieldEvent(
            address: Message.caller,
            number: 100,
            buffer: "Hello World!"
        ).emit(data: "")
    }
    
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
            WorldAccount(address: "contract"),
            WorldAccount(address: "user")
        ]
    }
    
    func testNoEvent() throws {
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitNoEvent(
            transactionInput: ContractCallTransactionInput(callerAddress: "user"),
            transactionOutput: transactionOutput
        )
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = []
        
        XCTAssertEqual(logs, expected)
    }
    
    func testSingleIndexedFieldEventNoData() throws {
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitSingleIndexedFieldEventNoData(
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
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitSingleIndexedFieldEventWithBufferData(
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
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitSingleIndexedFieldEventWithBigUintData(
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
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitMultipleIndexedFieldEventNoData(
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
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitMultipleEvents(
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
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitEventFromArgs(
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
        let _ = try EventTestsContract.testable(
            "contract",
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
