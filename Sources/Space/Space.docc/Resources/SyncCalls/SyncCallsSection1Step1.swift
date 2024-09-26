import Space

@Contract struct CalledContract {
    public func deposit() {
        // Implements the logic to handle a deposit.
        // This endpoint requires an input EGLD payment.
    }
    
    public func withdraw(amount: BigUint) -> TokenPayment {
        // Executes the logic to withdraw the specified amount.
        // Returns a TokenPayment that represents the amount withdrawn.
    }
    
    public func getTotalDepositedAmount() -> BigUint {
        // Retrieves the total deposited amount.
        // This is a view function that likely accesses a stored value.
    }
}
