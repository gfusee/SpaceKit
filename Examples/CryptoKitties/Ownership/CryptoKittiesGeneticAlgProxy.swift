import SpaceKit
import CryptoKittiesCommon

@Proxy enum CryptoKittiesGeneticAlgProxy {
    case generateKittyGenes(matron: Kitty, sire: Kitty)
}
