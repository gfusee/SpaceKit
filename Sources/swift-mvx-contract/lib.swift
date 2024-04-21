import MultiversX

@_expose(wasm, "init")
@_cdecl("init")
func initFunction() {

}

@_expose(wasm, "echoHelloWorld")
@_cdecl("echoHelloWorld")
func echoHelloWorld() {
    let bufferHandle = -100

    let test: Array<UInt8> = Array()

    let hello: MultiversX.Buffer = "Hello World!"
    let how: String = "How's it going?"
    let biguint: BigUint = 8

    let speech: String = "\(hello) \(how) Very nice weather, right? \(biguint)"

    speech.finish()
}
