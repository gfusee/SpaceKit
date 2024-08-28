import Space

@Codable public enum UserRole: Equatable {
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
    
    func canPerformAction() -> Bool {
        return self.canPropose()
    }
}
