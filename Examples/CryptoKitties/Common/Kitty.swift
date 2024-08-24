import MultiversX

let SECONDS_PER_MINUTE: UInt64 = 60
let MAX_COOLDOWN: UInt64 = 60 * 60 * 24 * 7
let MAX_TIREDNESS: UInt16 = 20

@Codable public struct Kitty {
    let genes: KittyGenes
    let birthTime: UInt64
    let cooldownEnd: UInt64
    let matronId: UInt32
    let sireId: UInt32
    let siringWithId: UInt32
    let nrChildren: UInt16
    let generation: UInt16
}

extension Kitty {
    public func isPregnant() -> Bool {
        return self.siringWithId != 0
    }
    
    public func getNextCooldownTime() -> UInt64 {
        let tiredness = self.nrChildren + self.generation / 2
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
