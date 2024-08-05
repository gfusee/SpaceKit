public enum EsdtLocalRolesFlag: Int64 {
    case none = 0b00000000
    case mint = 0b00000001
    case burn = 0b00000010
    case nftCreate = 0b00000100
    case nftAddQuantity = 0b00001000
    case nftBurn = 0b00010000
    case nftAddUri = 0b00100000
    case nftUpdateAttributes = 0b01000000
    case transfer = 0b10000000
}

public struct EsdtLocalRoles {
    let flags: Int64
    
    public init(flags: Int64) {
        self.flags = flags
    }
    
    public func contains(flag: EsdtLocalRolesFlag) -> Bool {
        // TODO: add tests
        return (self.flags & flag.rawValue) != EsdtLocalRolesFlag.none.rawValue
    }
}
