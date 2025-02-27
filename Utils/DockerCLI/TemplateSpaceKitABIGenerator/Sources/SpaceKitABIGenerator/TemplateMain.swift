import Foundation
import SpaceKit
import ##TARGET_NAME##

@ABIMeta(
    graphJSONContents: [
        "/app/.build/symbol-graphs/SpaceKit.symbols.json",
        "/app/.build/symbol-graphs/##TARGET_NAME##.symbols.json"
    ],
    spaceKitGraphJSONContent: "/app/.build/symbol-graphs/SpaceKit.symbols.json"
)
struct MyABIGenerator {}


func main() {
    // Ensure the program is invoked with a file path argument
    guard CommandLine.arguments.count > 1 else {
        print("Usage: cli_tool <output-file-path>")
        exit(1)
    }

    let outputFilePath = CommandLine.arguments[1]

    do {
        let abi = MyABIGenerator.getABI(contractName: "##TARGET_NAME##", version: "##SPACEKIT_VERSION##")
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(abi)
        
        // Write the JSON data to the specified file path
        let fileURL = URL(fileURLWithPath: outputFilePath)
        try jsonData.write(to: fileURL)
    } catch {
        // Handle any errors that occur
        print("An error occurred: \(error)")
        exit(1)
    }
}

// Run the main function
main()
