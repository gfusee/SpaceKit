#if !WASM
public func getAllABIExportableTypes() -> [String : ABIType] {
    var types: [String : ABIType] = [:]

    let allABITypeExtractorsClasses = Runtime.classes(conformTo: ABITypeExtractor.Type.self)
    for classIndice in allABITypeExtractorsClasses.indices {
        let classType: AnyClass = allABITypeExtractorsClasses[classIndice]
        let codableType = classType as! (any ABITypeExtractor.Type)
        
        if let abiType = codableType._extractABIType {
            let fullClassName = NSStringFromClass(classType)
            if fullClassName.starts(with: "SpaceKit") {
                let spaceKitExportableCodable = [
                    String(describing: TokenPayment.self)
                ]
                
                guard spaceKitExportableCodable.contains(codableType._abiTypeName) else {
                    continue
                }
            }
            
            types[codableType._abiTypeName] = abiType
        }
    }
    
    return types
}
#endif
