import SpaceKit

let SECONDS_PER_MINUTE: UInt64 = 60
let MAX_COOLDOWN: UInt64 = 60 * 60 * 24 * 7
let MAX_TIREDNESS: UInt16 = 20

@Codable public struct Kitty {
    public let genes: KittyGenes
    public let birthTime: UInt64
    public var cooldownEnd: UInt64
    public let matronId: UInt32
    public let sireId: UInt32
    public var siringWithId: UInt32
    public var numberOfChildren: UInt16
    public let generation: UInt16
    
    public static func new(
        genes: KittyGenes,
        birthTime: UInt64,
        cooldownEnd: UInt64 = 0,
        matronId: UInt32,
        sireId: UInt32,
        siringWithId: UInt32 = 0,
        numberOfChildren: UInt16 = 0,
        generation: UInt16
    ) -> Kitty {
        return Kitty(
            genes: genes,
            birthTime: birthTime,
            cooldownEnd: cooldownEnd,
            matronId: matronId,
            sireId: sireId,
            siringWithId: siringWithId,
            numberOfChildren: numberOfChildren,
            generation: generation
        )
    }
    
    public static func getDefault() -> Kitty {
        return Kitty(
            genes: KittyGenes.getDefault(),
            birthTime: 0,
            cooldownEnd: UInt64.max,
            matronId: 0,
            sireId: 0,
            siringWithId: 0,
            numberOfChildren: 0,
            generation: 0
        )
    }
    
    public func isPregnant() -> Bool {
        return self.siringWithId != 0
    }
    
    public func getNextCooldownTime() -> UInt64 {
        let tiredness = self.numberOfChildren + self.generation / 2
        if tiredness > MAX_TIREDNESS {
            return MAX_COOLDOWN;
        }

        let cooldown = SECONDS_PER_MINUTE << tiredness; // 2^(tiredness) minutes
        return if cooldown > MAX_COOLDOWN {
            MAX_COOLDOWN
        } else {
            cooldown
        }
    }
}
