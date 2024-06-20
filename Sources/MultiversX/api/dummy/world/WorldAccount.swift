#if !WASM
import Foundation
import BigInt

public struct EsdtBalance {
    var nonce: UInt64
    var balance: BigInt
}

public struct WorldAccount {
    package var addressData: Data
    package var balance: BigInt
    package var esdtBalances: [Data : [EsdtBalance]]
    
    public init(
        address: String,
        balance: BigInt = 0,
        esdtBalances: [Data : [EsdtBalance]] = [:]
    ) {
        self.addressData = address.toAddressData()
        self.balance = balance
        self.esdtBalances = esdtBalances
    }
    
    public func toAddress() -> Address {
        Address(buffer: MXBuffer(data: Array(self.addressData)))
    }
    
    public func getBalance() -> BigUint {
        return BigUint(bigEndianBuffer: MXBuffer(data: Array(self.balance.toBigEndianUnsignedData())))
    }
}

#endif
