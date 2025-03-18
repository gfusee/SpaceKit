#if !WASM
import Foundation
import BigInt

public struct ContractCallTransactionInput {
    public let callerAddress: String?
    public let egldValue: BigUint
    public let esdtValue: Vector<TokenPayment>
    
    public init(
        callerAddress: String? = nil,
        egldValue: BigUint = 0,
        esdtValue: Vector<TokenPayment> = Vector()
    ) {
        self.callerAddress = callerAddress
        self.egldValue = egldValue
        self.esdtValue = esdtValue
    }
    
    public func toTransactionInput(
        contractAddress: String,
        arguments: [any TopEncodeMulti & TopDecodeMulti]
    ) -> TransactionInput {
        let callerAddress = self.callerAddress ?? contractAddress
        var esdtValueArray: [TransactionInput.EsdtPayment] = []
        
        var argsVector: Vector<Buffer> = Vector()
        for arg in arguments {
            arg.multiEncode(output: &argsVector)
        }
        
        var argsData: [Data] = []
        argsVector.forEach { argBuffer in
            argsData.append(Data(argBuffer.toBytes()))
        }

        self.esdtValue.forEach { transfer in
            esdtValueArray.append(
                TransactionInput.EsdtPayment(
                    tokenIdentifier: Data(transfer.tokenIdentifier.buffer.toBytes()),
                    nonce: transfer.nonce,
                    amount: BigInt(bigUint: transfer.amount)
                )
            )
        }
        
        return TransactionInput(
            contractAddress: contractAddress.toAddressData(),
            callerAddress: callerAddress.toAddressData(),
            egldValue: BigInt(bigUint: self.egldValue),
            esdtValue: esdtValueArray,
            arguments: argsData
        )
    }
}

public struct TransactionInput: Sendable {
    public struct EsdtPayment: Sendable {
        let tokenIdentifier: Data
        let nonce: UInt64
        let amount: BigInt
    }

    public let contractAddress: Data
    public let callerAddress: Data
    public let egldValue: BigInt
    public let esdtValue: [EsdtPayment]
    private(set) var arguments: [Data]
    
    package init(
        contractAddress: Data,
        callerAddress: Data,
        egldValue: BigInt,
        esdtValue: [EsdtPayment],
        arguments: [Data]
    ) {
        self.contractAddress = contractAddress
        self.callerAddress = callerAddress
        self.egldValue = egldValue
        self.esdtValue = esdtValue
        self.arguments = arguments
    }
    
    public mutating func withArguments(args: Vector<Buffer>) {
        var argumentsData: [Data] = []
        args.forEach { argumentsData.append(Data($0.toBytes())) }
        self.arguments = argumentsData
    }

    // MARK: - Convert to Data

    public func toData() -> Data {
        var data = Data()
        
        data.append(self.contractAddress)
        data.append(self.callerAddress)
        data.append(self.egldValue.serialize())

        for esdt in self.esdtValue {
            var nonce = esdt.nonce
            let nonceData = Swift.withUnsafeBytes(of: &nonce) { Data($0) }
            
            data.append(esdt.tokenIdentifier)
            data.append(nonceData)
            data.append(esdt.amount.serialize())
        }
        
        for argument in self.arguments {
            data.append(argument)
        }

        return data
    }
}
#endif
