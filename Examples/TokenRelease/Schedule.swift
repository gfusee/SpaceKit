import Space

@Codable struct FixedAmountUnlockType {
    let periodUnlockAmount: BigUint
    let releasePeriod: UInt64
    let releaseTicks: UInt64
}

@Codable struct PercentageUnlockType {
    let periodUnlockPercentage: UInt8
    let releasePeriod: UInt64
    let releaseTicks: UInt64
}

@Codable enum UnlockType {
    case fixedAmount(FixedAmountUnlockType)
    case percentage(PercentageUnlockType)
}

@Codable struct Schedule {
    let groupTotalAmount: BigUint
    let unlockType: UnlockType
}
