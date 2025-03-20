import SpaceKit

@Controller public struct StorageController {
    @Storage(key: "ownerPercentFees") var ownerPercentFees: UInt64
}
