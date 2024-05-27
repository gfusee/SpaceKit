import MultiversX

@Contract
struct BalanceKeeperContract {
    @Storage(key: "totalBalance") var totalBalance: BigUint
    @Mapping(key: "balance") var balanceForUser: StorageMap<Address, BigUint>
    
    public mutating func increaseBalanceOfUser(userAddress: Address, value: BigUint, test: MXBuffer) -> MXBuffer {
        self.balanceForUser[userAddress] += value
        self.totalBalance += value
        
        return MXBuffer()
    }
    
    public func getBalanceOfUser(userAddress: Address) -> BigUint {
        return self.balanceForUser[userAddress]
    }
    
    public func getSelfAddress() -> Address {
        return Blockchain.getSCAddress()
    }
}
