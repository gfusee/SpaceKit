public struct Crypto {
    
    public static func verifyEd25519(
        key: Buffer,
        message: Buffer,
        signature: Buffer
    ) {
        let _ = API.managedVerifyEd25519(
            keyHandle: key.handle,
            messageHandle: message.handle,
            sigHandle: signature.handle
        )
    }
    
    public static func getSha256Hash(of value: Buffer) -> Buffer {
        var result = Buffer()
        
        let _ = API.managedSha256(
            inputHandle: value.handle,
            outputHandle: result.handle
        )
        
        return result
    }
    
}
