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
