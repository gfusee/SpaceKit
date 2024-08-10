import MultiversX

@Codable public enum UserRole {
    case none
    case proposer
    case boardMember
}

extension UserRole {
    func canSign() -> Bool {
        return self == .boardMember
    }
    
    func canDiscardAction() -> Bool {
        return self.canPropose()
    }
    
    func canPropose() -> Bool {
        return self == .boardMember || self == .proposer
    }
}
