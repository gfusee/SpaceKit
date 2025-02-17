import Foundation

enum TemplateProjectRepoLocation {
    case local(path: String)
    case remote(commitHash: String)
}

func fetchTemplateProject(
    in directory: URL,
    directoryName: String,
    repoLocation: TemplateProjectRepoLocation
) async throws(CLIError) {
    let spaceKitRepoUrl = "https://github.com/gfusee/SpaceKit.git"
    let tempDirCommand = "mktemp -d"
    
    let cloneCommand: String
    switch repoLocation {
    case .local(let path):
        cloneCommand = "git clone --local \(path) $TEMP_DIR"
    case .remote(let commitHash):
        cloneCommand = "git clone \(spaceKitRepoUrl) $TEMP_DIR && cd $TEMP_DIR && git checkout \(commitHash)"
    }
    
    let command = """
    set -e
    TEMP_DIR=$(\(tempDirCommand))
    trap 'rm -rf $TEMP_DIR' EXIT
    \(cloneCommand)
    cp -r $TEMP_DIR/Utils/Template \(directory.appendingPathComponent(directoryName).path)
    """
    
    _ = try await runInTerminal(
        currentDirectoryURL: directory,
        command: command
    )
}
