#if !WASM
import Foundation
import BigInt

public struct ContractCallTransactionInput {
    public let callerAddress: String?
    public let egldValue: BigUint
    public let esdtValue: MXArray<TokenPayment>
    
    public init(
        callerAddress: String? = nil,
        egldValue: BigUint = 0,
        esdtValue: MXArray<TokenPayment> = MXArray()
    ) {
        self.callerAddress = callerAddress
        self.egldValue = egldValue
        self.esdtValue = esdtValue
    }
    
    package func toTransactionInput(contractAddress: String) -> TransactionInput {
        let callerAddress = self.callerAddress ?? contractAddress
        var esdtValueArray: [TransactionInput.EsdtPayment] = []

        for transfer in self.esdtValue {
            esdtValueArray.append(
                TransactionInput.EsdtPayment(
                    tokenIdentifier: Data(transfer.tokenIdentifier.toBytes()),
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
            arguments: []
        )
    }
}

public struct TransactionInput {
    public struct EsdtPayment {
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
    
    public mutating func withArguments(args: MXArray<MXBuffer>) {
        var argumentsData: [Data] = []
        
        for arg in args {
            argumentsData.append(Data(arg.toBytes()))
        }
        
        self.arguments = argumentsData
    }
}
#endif
