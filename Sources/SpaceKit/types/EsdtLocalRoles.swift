public enum EsdtLocalRolesFlag: UInt64 {
    case none = 0b00000000
    case mint = 0b00000001
    case burn = 0b00000010
    case nftCreate = 0b00000100
    case nftAddQuantity = 0b00001000
    case nftBurn = 0b00010000
    case nftUpdateAttributes = 0b00100000
    case nftAddUri = 0b01000000
    case nftRecreate = 0b10000000
    case modifyCreator = 0b00000001_00000000
    case modifyRoyalties = 0b00000010_00000000
    case setNewUri = 0b00000100_00000000
    
    public func getRoleName() -> Buffer {
        return switch self {
        case .none:
            ""
        case .mint:
            "ESDTRoleLocalMint"
        case .burn:
            "ESDTRoleLocalBurn"
        case .nftCreate:
            "ESDTRoleNFTCreate"
        case .nftAddQuantity:
            "ESDTRoleNFTAddQuantity"
        case .nftBurn:
            "ESDTRoleNFTBurn"
        case .nftUpdateAttributes:
            "ESDTRoleNFTUpdateAttributes"
        case .nftAddUri:
            "ESDTRoleNFTAddURI"
        case .nftRecreate:
            "ESDTRoleNFTRecreate"
        case .modifyCreator:
            "ESDTRoleModifyCreator"
        case .modifyRoyalties:
            "ESDTRoleModifyRoyalties"
        case .setNewUri:
            "ESDTRoleSetNewURI"
        }
    }
}

public struct EsdtLocalRoles: Equatable {
    public private(set) var flags: UInt64
    
    public init(flags: UInt64) {
        self.flags = flags
    }
    
    public init(
        canMint: Bool = false,
        canBurn: Bool = false,
        canCreateNft: Bool = false,
        canAddNftQuantity: Bool = false,
        canBurnNft: Bool = false,
        canUpdateNftAttributes: Bool = false,
        canAddNftUri: Bool = false,
        canRecreateNft: Bool = false,
        canModifyCreator: Bool = false,
        canModifyRoyalties: Bool = false,
        canSetNewUri: Bool = false
    ) {
        var flags: UInt64 = EsdtLocalRolesFlag.none.rawValue
        
        if canMint {
            flags |= EsdtLocalRolesFlag.mint.rawValue
        }
        
        if canBurn {
            flags |= EsdtLocalRolesFlag.burn.rawValue
        }
        
        if canCreateNft {
            flags |= EsdtLocalRolesFlag.nftCreate.rawValue
        }
        
        if canAddNftQuantity {
            flags |= EsdtLocalRolesFlag.nftAddQuantity.rawValue
        }
        
        if canBurnNft {
            flags |= EsdtLocalRolesFlag.nftBurn.rawValue
        }
        
        if canUpdateNftAttributes {
            flags |= EsdtLocalRolesFlag.nftUpdateAttributes.rawValue
        }

        if canAddNftUri {
            flags |= EsdtLocalRolesFlag.nftAddUri.rawValue
        }
        
        if canSetNewUri {
            flags |= EsdtLocalRolesFlag.setNewUri.rawValue
        }
        
        if canModifyCreator {
            flags |= EsdtLocalRolesFlag.modifyCreator.rawValue
        }
        
        if canModifyRoyalties {
            flags |= EsdtLocalRolesFlag.modifyRoyalties.rawValue
        }
        
        if canRecreateNft {
            flags |= EsdtLocalRolesFlag.nftRecreate.rawValue
        }
        
        if canSetNewUri {
            flags |= EsdtLocalRolesFlag.setNewUri.rawValue
        }
        
        self.flags = flags
    }
    
    public func contains(flag: EsdtLocalRolesFlag) -> Bool {
        // TODO: add tests
        return (self.flags & flag.rawValue) != EsdtLocalRolesFlag.none.rawValue
    }
    
    public func forEachFlag(_ operations: (EsdtLocalRolesFlag) throws -> Void) rethrows {
        if self.contains(flag: .mint) {
            try operations(.mint)
        }
        
        if self.contains(flag: .burn) {
            try operations(.burn)
        }
        
        if self.contains(flag: .nftCreate) {
            try operations(.nftCreate)
        }
        
        if self.contains(flag: .nftAddQuantity) {
            try operations(.nftAddQuantity)
        }
        
        if self.contains(flag: .nftBurn) {
            try operations(.nftBurn)
        }
        
        if self.contains(flag: .nftUpdateAttributes) {
            try operations(.nftUpdateAttributes)
        }

        if self.contains(flag: .nftAddUri) {
            try operations(.nftAddUri)
        }
        
        if self.contains(flag: .nftRecreate) {
            try operations(.nftRecreate)
        }
        
        if self.contains(flag: .modifyCreator) {
            try operations(.modifyCreator)
        }

        if self.contains(flag: .modifyRoyalties) {
            try operations(.modifyRoyalties)
        }
        
        if self.contains(flag: .setNewUri) {
            try operations(.setNewUri)
        }
    }
    
    public mutating func addRoles(roles: EsdtLocalRoles) {
        self.flags |= roles.flags
    }
}
