import MultiversX

@Contract struct Empty {
    init() {
        let deposit = self.getDeposit()
        let deposit2 = deposit
    }
    
    func getDeposit() -> DepositInfo {
        let deposit = DepositInfo(arg1: 0, arg2: 0, arg3: 0, arg4: 0, arg5: 0, arg6: 0, arg7: 0, arg8: 0, arg9: 0, arg10: 0, arg11: 0, arg12: 0, arg13: 0, arg14: 0, arg15: 0, arg16: 0, arg17: 0, arg18: 0, arg19: 0, arg20: 0, arg21: 0, arg22: 0, arg23: 0, arg24: 0, arg25: 0, arg26: 0, arg27: 0, arg28: 0, arg29: 0, arg30: 0, arg31: 0, arg32: 0, arg33: 0)
        
        return deposit
    }
}
