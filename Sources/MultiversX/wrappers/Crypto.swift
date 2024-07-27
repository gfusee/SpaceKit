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
    
}
