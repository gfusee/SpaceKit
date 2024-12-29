#if !WASM
import Foundation
import SpaceKitABI
import SymbolKit
import SwiftSyntax

func getExtractABIFromSymbolGraphsFunction(graphJSONContents: [String], spaceKitGraphJSONContent: String) throws(ABIMetaMacroError) -> DeclSyntax {
    let spaceKitSymbolGraph = try parseSymbolGraphFromJSON(for: spaceKitGraphJSONContent)
    
    guard let abiConstructorExtractorProtocolIdentifier = getIdentifierOfStructOrProtocolFromSymbolGraph(symbolGraph: spaceKitSymbolGraph, displayName: "ABIConstructorExtractor") else {
        throw ABIMetaMacroError.noABIConstructorExtractorSymbolFound
    }
    
    guard let abiEndpointsExtractorProtocolIdentifier = getIdentifierOfStructOrProtocolFromSymbolGraph(symbolGraph: spaceKitSymbolGraph, displayName: "ABIEndpointsExtractor") else {
        throw ABIMetaMacroError.noABIEndpointsExtractorSymbolFound
    }
    
    guard let abiTypeExtractorProtocolIdentifier = getIdentifierOfStructOrProtocolFromSymbolGraph(symbolGraph: spaceKitSymbolGraph, displayName: "ABITypeExtractor") else {
        throw ABIMetaMacroError.noABITypeExtractorSymbolFound
    }
    
    guard let abiEventExtractorProtocolIdentifier = getIdentifierOfStructOrProtocolFromSymbolGraph(symbolGraph: spaceKitSymbolGraph, displayName: "ABIEventExtractor") else {
        throw ABIMetaMacroError.noABIEventExtractorSymbolFound
    }
    
    var hasConstructor: Bool = false
    var structsConformingToABIEndpointsExtractorDisplayNames: [String] = []
    var structsConformingToABITypeExtractorDisplayNames: [String] = []
    var structsConformingToABIEventExtractorDisplayNames: [String] = []
    
    for jsonContent in graphJSONContents {
        let symbolGraph = try parseSymbolGraphFromJSON(for: jsonContent)
        
        if !hasConstructor {
            if doesSymbolGraphHaveInit(symbolGraph: symbolGraph) {
                hasConstructor = true
            }
        }
        
        structsConformingToABIEndpointsExtractorDisplayNames.append(contentsOf: getDisplayNamesOfStructsConformingToProtocol(
            protocolIdentifier: abiEndpointsExtractorProtocolIdentifier,
            in: symbolGraph
        ))
        
        structsConformingToABITypeExtractorDisplayNames.append(contentsOf: getDisplayNamesOfStructsConformingToProtocol(
            protocolIdentifier: abiTypeExtractorProtocolIdentifier,
            in: symbolGraph
        ))
        
        structsConformingToABIEventExtractorDisplayNames.append(contentsOf: getDisplayNamesOfStructsConformingToProtocol(
            protocolIdentifier: abiEventExtractorProtocolIdentifier,
            in: symbolGraph
        ))
    }
    
    let constructorExtractionExpression = if hasConstructor {
        "let constructor = SpaceKitInitConstructorExtractor._extractABIConstructor"
    } else {
        "let constructor = ABIConstructor(inputs: [], outputs: [])"
    }
    
    let endpointsExtractionArrayItems = structsConformingToABIEndpointsExtractorDisplayNames
        .map { "\($0)._extractABIEndpoints" }
        .joined(separator: ",\n")
    
    let requiredTypesExtractionArrayItems = structsConformingToABIEndpointsExtractorDisplayNames
        .map { "\($0)._extractRequiredABITypes" }
        .joined(separator: ",\n")
    
    let typeExtractionExpressions = """
        let requiredTypesArrayOfMaps = [
            \(requiredTypesExtractionArrayItems)
        ]
        
        for map in requiredTypesArrayOfMaps {
            requiredTypes.merge(map) { _, new in
                new
            }
        }
        """
    
    let eventExtractionArrayItems = structsConformingToABIEventExtractorDisplayNames
        .map { "\($0)._extractABIEvent" }
        .joined(separator: ",\n")
    
    return """
    public static func getABI() -> ABI {
        \(raw: constructorExtractionExpression)
    
        let endpoints: [ABIEndpoint] = [
            \(raw: endpointsExtractionArrayItems)
        ].flatMap { $0 }
    
        var requiredTypes: [String : ABIType] = [:]
        \(raw: typeExtractionExpressions)
    
        let events: [ABIEvent] = [
            \(raw: eventExtractionArrayItems)
        ]
    
        return ABI(
            buildInfo: ABIBuildInfo(
                framework: ABIBuildInfoFramework(
                    name: "SpaceKit",
                    version: ""
                )
            ),
            name: "",
            constructor: constructor,
            endpoints: endpoints,
            events: events,
            types: requiredTypes
        )
    }
    """
}

private func getDisplayNamesOfStructsConformingToProtocol(
    protocolIdentifier: String,
    in symbolGraph: SymbolGraph
) -> [String] {
    let structsConformingToProtocolIdentifier: [String] = symbolGraph.relationships
        .compactMap { relationship in
            guard relationship.kind == .conformsTo && relationship.target == protocolIdentifier else {
                return nil
            }
            
            return relationship.source
        }
    
    return structsConformingToProtocolIdentifier
        .compactMap { getDisplayNameOfStructOrProtocolFromSymbolGraph(symbolGraph: symbolGraph, identifier: $0) }
}

private func getIdentifierOfStructOrProtocolFromSymbolGraph(
    symbolGraph: SymbolGraph,
    displayName: String
) -> String? {
    for symbol in symbolGraph.symbols {
        if symbol.value.names.title == displayName {
            return symbol.key.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    return nil
}

private func getDisplayNameOfStructOrProtocolFromSymbolGraph(
    symbolGraph: SymbolGraph,
    identifier: String
) -> String? {
    for symbol in symbolGraph.symbols {
        if symbol.value.identifier.precise == identifier {
            return symbol.value.names.title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    return nil
}

private func parseSymbolGraphFromJSON(for content: String) throws(ABIMetaMacroError) -> SymbolGraph {
    do {
        let fileURL = URL(fileURLWithPath: content)
        let data = try Data(contentsOf: fileURL)

        // Decode the JSON data into an ABI object
        let decoder = JSONDecoder()
        return try decoder.decode(SymbolGraph.self, from: data)
    } catch {
        throw ABIMetaMacroError.cannotDecodeSymbolGraph
    }
}

private func doesSymbolGraphHaveInit(symbolGraph: SymbolGraph) -> Bool {
    symbolGraph.symbols
        .contains(where: { symbol in
            guard let subHeading = symbol.value.names.subHeading else {
                return false
            }
            
            return symbol.value.kind.identifier == .func && subHeading.contains(where: { $0.spelling == "initialize"} )
        })
}
#endif
