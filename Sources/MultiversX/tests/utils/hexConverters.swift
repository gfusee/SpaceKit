#if !WASM
import Foundation

extension Data {
    public func hexEncodedString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    public var hexadecimal: Data {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        return data
    }
    
    public var hexadecimalString: String {
        let data = Data(self.utf8)
        return data.map{ String(format:"%02x", $0) }.joined()
    }
}
#endif
