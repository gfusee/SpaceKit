#if !WASM
import Foundation
import BigInt

public struct WorldAccount {
    package var addressData: Data
    package var balance: BigInt
    
    public init(
        address: String,
        balance: BigInt = 0
    ) {
        self.addressData = address.toAddressData()
        self.balance = balance
    }
    
    public func toAddress() -> Address {
        Address(buffer: MXBuffer(data: Array(self.addressData)))
    }
    
    public func getBalance() -> BigUint {
        return BigUint(bigEndianBuffer: MXBuffer(data: Array(self.balance.toBigEndianUnsignedData())))
    }
}

#endif
