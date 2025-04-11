import SwiftSyntax
import SwiftSyntaxMacros

extension FunctionDeclSyntax {
    func assertOptionalArgsCorrectness() throws(ControllerMacroError) {
        var hasOptionalArgument = false
        var hasMultiValueEncoded = false
        let functionName = "\(self.name.trimmed)"
        
        for parameter in self.signature.parameterClause.parameters {
            if hasMultiValueEncoded {
                throw .multiValueEncodedShouldBeTheLastParameter(endpointName: functionName)
            }
            
            let type = "\(parameter.type.trimmed)"
            let multiValueEncodedRegex = /^MultiValueEncoded<.+>$/
            
            if type.wholeMatch(of: multiValueEncodedRegex) != nil {
                hasMultiValueEncoded = true
            } else {
                let optionalArgumentRegex = /^OptionalArgument<.+>$/
                if type.wholeMatch(of: optionalArgumentRegex) != nil {
                    hasOptionalArgument = true
                } else {
                    if hasOptionalArgument {
                        throw .onlyOptionalArgumentOrMultiValueEncodedAllowed(endpointName: functionName)
                    }
                }
            }
        }
    }
}
