import MultiversX
import CryptoKittiesRandom

@Codable public struct Color {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
}

extension Color {
    public static func getDefault() -> Color {
        return Color(
            red: 0,
            green: 0,
            blue: 0
        )
    }
    
    public static func getRandom(random: inout Random) -> Color {
        return Color(
            red: random.nextU8(),
            green: random.nextU8(),
            blue: random.nextU8()
        )
    }
    
    public func mixWith(otherColor: Color, ratioFirst: UInt8, ratioSecond: UInt8) -> Color {
        let ratioFirst = UInt16(ratioFirst)
        let ratioSecond = UInt16(ratioSecond)
        
        let selfRed = UInt16(self.red)
        let otherColorRed = UInt16(otherColor.red)
        
        let selfGreen = UInt16(self.green)
        let otherColorGreen = UInt16(otherColor.green)
        
        let selfBlue = UInt16(self.blue)
        let otherColorBlue = UInt16(otherColor.blue)
        
        let red = UInt8((selfRed * ratioFirst + otherColorRed * ratioSecond) / 100)
        let green = UInt8((selfGreen * ratioFirst + otherColorGreen * ratioSecond) / 100)
        let blue = UInt8((selfBlue * ratioFirst + otherColorBlue * ratioSecond) / 100)

        return Color(
            red: red,
            green: green,
            blue: blue
        )
    }
    
    public func intoUInt64() -> UInt64 {
        let selfRed = UInt64(self.red).bigEndian
        
        // Why is only self.red used and not the other fields? This is a reproduction of the Rust example
        return (selfRed << 4 | selfRed) << 4 | selfRed
    }
}
