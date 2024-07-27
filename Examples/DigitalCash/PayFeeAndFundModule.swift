import MultiversX

struct PayFeeAndFundModule {
    func payFeeAndFundESDT(
        address: Address,
        valability: UInt64
    ) {
        var payments = Message.allEsdtTransfers
        let fee = payments.get(0)
        let caller = Message.caller
        
        s
    }
}
