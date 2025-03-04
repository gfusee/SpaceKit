import SpaceKit

let MAX_ORDERS_PER_USER: UInt32 = 100
let PERCENT_BASE_POINTS: UInt64 = 100_000
let FEE_PENALTY_INCREASE_PERCENT: UInt64 = 1_000
let FEE_PENALTY_INCREASE_EPOCH: UInt64 = 5
let FREE_ORDER_FROM_STORAGE_MIN_PENALTIES: UInt64 = 6

@Codable public struct Payment {
    let tokenIdentifier: TokenIdentifier
    var amount: BigUint
}

@Codable public struct Transfer {
    let to: Address
    var payment: Payment
}

@Codable public struct Order {
    let id: UInt64
    let creator: Address
    let matchProvider: Address
    let inputAmount: BigUint
    let outputAmount: BigUint
    let feeConfig: FeeConfig
    let dealConfig: DealConfig
    let createEpoch: UInt64
    let orderType: OrderType
}

@Codable public struct OrderInputParams {
    let amount: BigUint
    let matchProvider: Address
    let feeConfig: FeeConfig
    let dealConfig: DealConfig
}

@Codable public enum OrderType {
    case buy
    case sell
}

@Codable public enum FeeConfigEnum {
    case fixed
    case percent
}

@Codable public struct FeeConfig {
    let feeType: FeeConfigEnum
    let fixedFee: BigUint
    let percentFee: UInt64
}

@Codable public struct DealConfig {
    let matchProviderPercent: UInt64
}

struct CommonHelpers {
    func newOrder(
        id: UInt64,
        payment: Payment,
        params: OrderInputParams,
        orderType: OrderType
    ) -> Order {
        return Order(
            id: id,
            creator: Message.caller,
            matchProvider: params.matchProvider,
            inputAmount: payment.amount,
            outputAmount: params.amount,
            feeConfig: params.feeConfig,
            dealConfig: params.dealConfig,
            createEpoch: Blockchain.getBlockEpoch(),
            orderType: orderType
        )
    }
    
    func calculateFeeAmount(
        amount: BigUint,
        feeConfig: FeeConfig
    ) -> BigUint {
        return switch feeConfig.feeType {
        case .fixed:
            feeConfig.fixedFee
        case .percent:
            amount * BigUint(value: feeConfig.percentFee) / BigUint(value: PERCENT_BASE_POINTS)
        }
    }
    
    func calculateAmountAfterFee(
        amount: BigUint,
        feeConfig: FeeConfig
    ) -> BigUint {
        return amount - self.calculateFeeAmount(amount: amount, feeConfig: feeConfig)
    }
    
    func ruleOfThree(
        part: BigUint,
        total: BigUint,
        value: BigUint
    ) -> BigUint {
        return part * value / total
    }
}
