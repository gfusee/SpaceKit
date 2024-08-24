import CryptoKittiesRandom
import MultiversX

public struct KittyGenes {
    let furColor: Color
    let eyeColor: Color
    let meowPower: UInt8
    
    public static func getRandom(random: inout Random) -> KittyGenes {
        return KittyGenes(
            furColor: Color.getRandom(random: &random),
            eyeColor: Color.getRandom(random: &random),
            meowPower: random.nextU8()
        )
    }
    
    public func intoUInt64() -> UInt64 {
        (self.furColor.intoUInt64() << 12 | self.eyeColor.intoUInt64()) << 4 | UInt64(self.meowPower).bigEndian
    }
}
