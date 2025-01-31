import SpaceKit

@Codable public struct FixedAmountUnlockType {
    let periodUnlockAmount: BigUint
    let releasePeriod: UInt64
    let releaseTicks: UInt64
}

@Codable public struct PercentageUnlockType {
    let periodUnlockPercentage: UInt8
    let releasePeriod: UInt64
    let releaseTicks: UInt64
}

@Codable public enum UnlockType {
    case fixedAmount(FixedAmountUnlockType)
    case percentage(PercentageUnlockType)
}

@Codable public struct Schedule {
    let groupTotalAmount: BigUint
    let unlockType: UnlockType
}
