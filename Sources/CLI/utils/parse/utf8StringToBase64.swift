extension String {
    func toBase64() -> String {
        guard let base64Data = self.data(using: .utf8)?.base64EncodedData(),
              let base64String = String(data: base64Data, encoding: .utf8) else {
            // TODO: handle unwrapping errors
            fatalError()
        }
        
        return base64String
    }
}
