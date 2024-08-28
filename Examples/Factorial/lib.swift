import Space

@Contract struct Factorial {
    public func factorial(value: BigUint) -> BigUint {
        let one: BigUint = 1
        
        if value == 0 {
            return one
        }
        
        var result: BigUint = 1
        var x: BigUint = 1
        
        while x <= value {
            result = result * x
            x = x + 1
        }
        
        return result
    }
}
