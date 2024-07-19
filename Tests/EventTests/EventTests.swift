import XCTest
import MultiversX

@Event(dataType: MXBuffer) struct TestSingleIndexedFieldMXBufferDataEvent {
    let address: Address
}

@Event(dataType: BigUint) struct TestSingleIndexedFieldBigUintDataEvent {
    let address: Address
}

@Event(dataType: MXBuffer) struct TestMultipleIndexedFieldEvent {
    let address: Address
    let number: BigUint
    let buffer: MXBuffer
}

@Contract struct EventTestsContract {
    init() {
        let data: MXBuffer = "Hello World!"
        TestSingleIndexedFieldMXBufferDataEvent(address: Message.caller).emit(data: data)
        
        TestMultipleIndexedFieldEvent(
            address: Message.caller,
            number: 100,
            buffer: "Hello World!"
        ).emit()
    }
    
    public func emitNoEvent() {
        
    }
    
    public func emitSingleIndexedFieldEventNoData() {
        TestSingleIndexedFieldMXBufferDataEvent(address: Message.caller).emit()
    }
    
    public func emitSingleIndexedFieldEventWithBufferData() {
        let data: MXBuffer = "Hello World!"
        TestSingleIndexedFieldMXBufferDataEvent(address: Message.caller).emit(data: data)
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
        ).emit()
    }
    
    public func emitMultipleEvents() {
        let data: MXBuffer = "Hello World!"
        TestSingleIndexedFieldMXBufferDataEvent(address: Message.caller).emit(data: data)
        
        TestMultipleIndexedFieldEvent(
            address: Message.caller,
            number: 100,
            buffer: "Hello World!"
        ).emit()
    }
    
    public func emitEventFromArgs(
        addressTopic: Address,
        numberTopic: BigUint,
        bufferTopic: MXBuffer,
        data: MXBuffer
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
        
        try contract.emitNoEvent(callerAddress: "user", transactionOutput: transactionOutput)
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = []
        
        XCTAssertEqual(logs, expected)
    }
    
    func testSingleIndexedFieldEventNoData() throws {
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitSingleIndexedFieldEventNoData(callerAddress: "user", transactionOutput: transactionOutput)
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: ["00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"],
                data: ""
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testSingleIndexedFieldEventWithBufferData() throws {
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitSingleIndexedFieldEventWithBufferData(callerAddress: "user", transactionOutput: transactionOutput)
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: ["00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"],
                data: "48656c6c6f20576f726c6421"
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testSingleIndexedFieldEventWithBigUintData() throws {
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitSingleIndexedFieldEventWithBigUintData(callerAddress: "user", transactionOutput: transactionOutput)
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: ["00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"],
                data: "64"
            )
        ]
        
        XCTAssertEqual(logs, expected)
    }
    
    func testMultipleIndexedFieldEventNoData() throws {
        let contract = try EventTestsContract.testable("contract")
        let transactionOutput = TransactionOutput()
        
        try contract.emitMultipleIndexedFieldEventNoData(callerAddress: "user", transactionOutput: transactionOutput)
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: [
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
        
        try contract.emitMultipleEvents(callerAddress: "user", transactionOutput: transactionOutput)
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: ["00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"],
                data: "48656c6c6f20576f726c6421"
            ),
            TransactionOutputLog(
                topics: [
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
        let _ = try EventTestsContract.testable("contract", callerAddress: "user", transactionOutput: transactionOutput)
        
        let logs = transactionOutput.getLogs()
        let expected: [TransactionOutputLog] = [
            TransactionOutputLog(
                topics: ["00000000000000000000757365725f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f"],
                data: "48656c6c6f20576f726c6421"
            ),
            TransactionOutputLog(
                topics: [
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
