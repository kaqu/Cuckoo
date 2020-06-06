import class Foundation.NSFileManager.FileManager
import class Foundation.FileHandle
import struct Foundation.NSURL.URL
import struct Foundation.NSData.Data
import struct Foundation.NSObjCRuntime.ObjCBool

internal extension FileManager {

  func directoryExists(atPath path: String) -> Bool {
      var isDirectory = ObjCBool(true)
      FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
      return isDirectory.boolValue
  }
}

// TODO: add flag to allow override or append mode
public func fileOutput(filePath: String) -> (String) -> Void {
  var filePath = filePath
  if filePath.hasPrefix("~/") {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser.absoluteString
    filePath = homeDir.suffix(from: homeDir.index(homeDir.startIndex, offsetBy: 7)) + String(filePath[filePath.index(filePath.startIndex, offsetBy: 2)..<filePath.endIndex])
  } else { /**/ }
  if !FileManager.default.fileExists(atPath: filePath) {
    FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
  } else { /**/ }
  let fileHandle = try! FileHandle(forWritingTo: URL(filePath: filePath))
  return fileHandle.write
}

// TODO: add flag to allow override or append mode
public func fileOutputData(filePath: String) -> (Data) -> Void {
  var filePath = filePath
  if filePath.hasPrefix("~/") {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser.absoluteString
    filePath = homeDir.suffix(from: homeDir.index(homeDir.startIndex, offsetBy: 7)) + String(filePath[filePath.index(filePath.startIndex, offsetBy: 2)..<filePath.endIndex])
  } else { /**/ }
  if !FileManager.default.fileExists(atPath: filePath) {
    FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
  } else { /**/ }
  let fileHandle = try! FileHandle(forWritingTo: URL(filePath: filePath))
  return fileHandle.write
}
