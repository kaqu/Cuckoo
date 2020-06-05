import struct Foundation.NSURL.URL
import class Foundation.NSFileManager.FileManager

internal extension URL {
  
  init(directoryPath: String) {
    var directoryPath = directoryPath
    if directoryPath.hasPrefix("~/") {
      directoryPath = FileManager.default.homeDirectoryForCurrentUser.absoluteString + String(directoryPath[directoryPath.index(directoryPath.startIndex, offsetBy: 2)..<directoryPath.endIndex])
    } else { /**/ }
    guard
      !directoryPath.isEmpty,
      FileManager.default.directoryExists(atPath: directoryPath),
      let directoryURL = URL(string: "file://\(directoryPath)")
      else { fatalError("Invalid or missing directory: \(directoryPath)") } // TODO: error?
    self = directoryURL
  }
  
  init(filePath: String) {
    var filePath = filePath
    if filePath.hasPrefix("~/") {
      filePath = FileManager.default.homeDirectoryForCurrentUser.absoluteString + String(filePath[filePath.index(filePath.startIndex, offsetBy: 2)..<filePath.endIndex])
    } else { /**/ }
    guard
      !filePath.isEmpty,
      FileManager.default.fileExists(atPath: filePath),
      let directoryURL = URL(string: "file://\(filePath)")
      else { fatalError("Invalid or missing file: \(filePath)") } // TODO: error?
    self = directoryURL
  }
}
