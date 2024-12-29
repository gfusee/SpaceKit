import SpaceKit

@Controller public struct CheckPauseController {
    @Storage(key: "isContractPaused") var isContractPaused: Bool
    
    public func isPaused() -> Bool {
        return self.isContractPaused
    }
    
    public func checkPause() -> Bool {
        return self.isPaused()
    }
    
    public mutating func pause() {
        assertOwner()
        self.isContractPaused = true
    }
    
    public mutating func unpause() {
        assertOwner()
        self.isContractPaused = false
    }
    
    func requirePaused() {
        require(
            self.isContractPaused,
            "Contract is not paused"
        )
    }
    
    func requireNotPaused() {
        require(
            self.isContractPaused,
            "Contract is paused"
        )
    }
}
