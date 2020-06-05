import struct Foundation.NSURL.URL
import class Foundation.NSFileManager.FileManager

internal extension URL {
  
  init(directory: String) {
    var directory = directory
    if directory.hasPrefix("~/") {
      directory = FileManager.default.homeDirectoryForCurrentUser.absoluteString + String(directory[directory.index(directory.startIndex, offsetBy: 2)..<directory.endIndex])
    } else { /**/ }
    guard
      !directory.isEmpty,
      FileManager.default.directoryExists(atPath: directory),
      let directoryURL = URL(string: "file://\(directory)")
      else { fatalError("Invalid directory: \(directory)") } // TODO: error?
    self = directoryURL
  }
}
