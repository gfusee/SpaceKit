public struct Message {
    private init() {}
    
    public static var egldValue: BigUint {
        let valueHandle = getNextHandle()
        
        API.bigIntGetCallValue(dest: valueHandle)
        
        return BigUint(handle: valueHandle)
    }
}
