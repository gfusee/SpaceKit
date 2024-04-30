import MultiversX

@Contract
struct Contract {
    @Storage(key: "testStorage") var testStorage: BigUint
    
    public mutating func echoHelloWorld() -> MXBuffer {
        let hello: MXBuffer = "Hello World!"
        let how: MXBuffer = "How's it going?"
        let biguint: BigUint = 8
        
        return "\(hello) \(how) Very nice weather, right? \(biguint)"
    }
    
    public mutating func getTestStorageValue() -> BigUint {
        self.testStorage
    }
}
