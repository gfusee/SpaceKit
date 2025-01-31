#if !WASM
public protocol ContractEndpointSelector {
    init()
    
    /// Returns false if the function doesn't exist, true otherwise.
    mutating func _callEndpoint(name: String) -> Bool
}

extension Array<ContractEndpointSelector.Type>: ContractEndpointSelector {
    public mutating func _callEndpoint(name: String) -> Bool {
        for selectorType in self {
            var selector = selectorType.init()
            
            if selector._callEndpoint(name: name) {
                return true
            }
        }
        
        return false
    }
}
#endif
