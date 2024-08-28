import Space
import CryptoKittiesCommon
import CryptoKittiesRandom

@Contract struct KittyGeneticAlg {
    public func generateKittyGenes(
        matron: Kitty,
        sire: Kitty
    ) -> KittyGenes {
        var random = Random(
            seed: Blockchain.getBlockRandomSeed(),
            salt: Message.transactionHash
        )
        
        let furColorPercentage = 1 + random.nextU8() % 99
        let matronFurColor = matron.genes.furColor
        let sireFurColor = sire.genes.furColor
        let kittyFurColor = matronFurColor.mixWith(
            otherColor: sireFurColor,
            ratioFirst: furColorPercentage,
            ratioSecond: 100 - furColorPercentage
        )
        
        let eyeColorPercentage = 1 + random.nextU8() % 99
        let matronEyeColor = matron.genes.eyeColor
        let sireEyeColor = sire.genes.eyeColor
        let kittyEyeColor = matronEyeColor.mixWith(
            otherColor: sireEyeColor,
            ratioFirst: eyeColorPercentage,
            ratioSecond: 100 - eyeColorPercentage
        )
        
        let kittyMeowPower = matron.genes.meowPower / 2 + sire.genes.meowPower / 2
        
        return KittyGenes.new(
            furColor: kittyFurColor,
            eyeColor: kittyEyeColor,
            meowPower: kittyMeowPower
        )
    }
}
