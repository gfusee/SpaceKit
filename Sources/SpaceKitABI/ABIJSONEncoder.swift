#if !WASM
import Foundation

public class ABIJSONEncoder: JSONEncoder, @unchecked Sendable {
    public override init() {
        super.init()
        
        self.outputFormatting = .prettyPrinted.union(.sortedKeys)
    }
    
    public override func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let data = try super.encode(value)

        // Convert data to a string
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return data
        }

        // Use Swift's Regex API to remove '__spacekit_json_n__<field name>__' pattern
        let regex = /__spacekit_json_\d+__(.*?)/
        let transformedString = jsonString.replacing(regex) { match in
            return "\(match.1)"
        }

        // Convert the transformed string back to data
        guard let transformedData = transformedString.data(using: .utf8) else {
            return data
        }

        return transformedData
    }
}
#endif
