public struct Crypto {
    
    public static func verifyEd25519(
        key: MXBuffer,
        message: MXBuffer,
        signature: MXBuffer
    ) {
        let _ = API.managedVerifyEd25519(
            keyHandle: key.handle,
            messageHandle: message.handle,
            sigHandle: signature.handle
        )
    }
    
    public static func getSha256Hash(of value: MXBuffer) -> MXBuffer {
        var result = MXBuffer()
        
        let _ = API.managedSha256(
            inputHandle: value.handle,
            outputHandle: result.handle
        )
        
        return result
    }
    
}
