public protocol ContractEndpointSelector {
    mutating func callEndpoint(name: String)
}
