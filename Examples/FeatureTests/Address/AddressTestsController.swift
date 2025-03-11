import SpaceKit

@Controller public struct AddressTestsController {
    public func checkIfIsSmartContract(address: Address) -> Bool {
        address.isSmartContract
    }
}
