import Foundation

extension String {
    func getAbsolutePath() -> String {
        URL(fileURLWithPath: self).absoluteURL.path
    }
}
