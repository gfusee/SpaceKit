import MultiversX

@Contract
struct BalanceKeeperContract {
    @Storage(key: "totalBalance") var totalBalance: BigUint
    @Mapping(key: "balance") var balanceForUser: StorageMap<Address, BigUint>
    
    public mutating func increaseBalanceOfUser(userAddress: Address, value: BigUint) {
        self.balanceForUser[userAddress] += value
        self.totalBalance += value
        
        var nestedEncodeOutput = MXBuffer()
        8.depEncode(dest: &nestedEncodeOutput)
    }
    
    public func getBalanceOfUser(userAddress: Address) -> BigUint {
        return self.balanceForUser[userAddress]
    }
    
    public func getSelfAddress() -> Address {
        return Blockchain.getSCAddress()
    }
}
