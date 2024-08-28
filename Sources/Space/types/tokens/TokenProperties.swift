@Codable public struct TokenProperties {
    let numDecimals: UInt32
    let canFreeze: Bool
    let canWipe: Bool
    let canPause: Bool
    let canTransferCreateRole: Bool
    let canMint: Bool
    let canBurn: Bool
    let canChangeOwner: Bool
    let canUpgrade: Bool
    let canAddSpecialRoles: Bool
}

@Codable public struct NonFungibleTokenProperties {
    var canFreeze: Bool
    var canWipe: Bool
    var canPause: Bool
    var canTransferCreateRole: Bool
    var canChangeOwner: Bool
    var canUpgrade: Bool
    var canAddSpecialRoles: Bool
}

extension NonFungibleTokenProperties {
    // TODO: remove once @Codable creates a public default init
    public static func new(
        canFreeze: Bool,
        canWipe: Bool,
        canPause: Bool,
        canTransferCreateRole: Bool,
        canChangeOwner: Bool,
        canUpgrade: Bool,
        canAddSpecialRoles: Bool
    ) -> NonFungibleTokenProperties {
        return NonFungibleTokenProperties(
            canFreeze: canFreeze,
            canWipe: canWipe,
            canPause: canPause,
            canTransferCreateRole: canTransferCreateRole,
            canChangeOwner: canChangeOwner,
            canUpgrade: canUpgrade,
            canAddSpecialRoles: canAddSpecialRoles
        )
    }
}

public struct TokenPropertiesArgument {
    let canFreeze: Bool?
    let canWipe: Bool?
    let canPause: Bool?
    var canTransferCreateRole: Bool?
    var canMint: Bool?
    var canBurn: Bool?
    let canChangeOwner: Bool?
    let canUpgrade: Bool?
    let canAddSpecialRoles: Bool?
}

extension TokenPropertiesArgument: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        if let canFreeze = self.canFreeze {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canFreeze"))
            output.pushSingleValue(arg: canFreeze)
        }
        
        if let canWipe = self.canWipe {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canWipe"))
            output.pushSingleValue(arg: canFreeze)
        }
        
        if let canPause = self.canPause {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canPause"))
            output.pushSingleValue(arg: canPause)
        }
        
        if let canTransferCreateRole = self.canTransferCreateRole {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canTransferNFTCreateRole"))
            output.pushSingleValue(arg: canTransferCreateRole)
        }
        
        if let canMint = self.canMint {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canMint"))
            output.pushSingleValue(arg: canMint)
        }
        
        if let canBurn = self.canBurn {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canBurn"))
            output.pushSingleValue(arg: canBurn)
        }
        
        if let canChangeOwner = self.canChangeOwner {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canChangeOwner"))
            output.pushSingleValue(arg: canChangeOwner)
        }
        
        if let canUpgrade = self.canUpgrade {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canUpgrade"))
            output.pushSingleValue(arg: canUpgrade)
        }
        
        if let canAddSpecialRoles = self.canAddSpecialRoles {
            output.pushSingleValue(arg: MXBuffer(stringLiteral: "canAddSpecialRoles"))
            output.pushSingleValue(arg: canAddSpecialRoles)
        }
    }
}
