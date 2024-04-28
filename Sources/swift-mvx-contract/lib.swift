import MultiversX

@Contract
struct Contract {
    public func echoHelloWorld() -> MXBuffer {
        let hello: MXBuffer = "Hello World!"
        let how: MXBuffer = "How's it going?"
        let biguint: BigUint = 8
        
        return "\(hello) \(how) Very nice weather, right? \(biguint)"
    }
}
