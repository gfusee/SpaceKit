import MultiversX

@Contract
struct Contract {
    public func echoHelloWorld() -> MXBuffer {
        let hello: StaticString = "Hello World!"
        let how: StaticString = "How's it going?"
        let biguint: BigUint = 8
        
        return "\(hello) \(how) Very nice weather, right? \(biguint)"
    }
}
