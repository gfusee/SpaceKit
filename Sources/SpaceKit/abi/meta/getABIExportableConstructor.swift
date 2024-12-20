#if !WASM
public func getABIExportableConstructor() -> ABIConstructor? {
    let allABITypeExtractorsClasses = Runtime.classes(conformTo: ABIConstructorExtractor.Type.self)
    
    if let classType: AnyClass = allABITypeExtractorsClasses.first {
        let constructorType = classType as! (any ABIConstructorExtractor.Type)
        
        let fullClassName = NSStringFromClass(classType)
        guard !fullClassName.starts(with: "SpaceKit") else {
            return nil
        }
        
        return constructorType._extractABIConstructor
    }
    
    return nil
}
#endif
