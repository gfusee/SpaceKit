public struct Blockchain {
    private init() {}
    
    public static func getSCAddress() -> Address {
        let handle = getNextHandle()
        
        API.managedSCAddress(resultHandle: handle)
        
        return Address(handle: handle)
    }
    
    public static func getBlockTimestamp() -> UInt64 { // TODO: add tests
        return UInt64(API.getBlockTimestamp()) // TODO: is this cast fine?
    }
}
