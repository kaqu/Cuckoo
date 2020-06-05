import class Foundation.NSFileManager.FileManager
import struct Foundation.NSObjCRuntime.ObjCBool

internal extension FileManager {

  func directoryExists(atPath path: String) -> Bool {
      var isDirectory = ObjCBool(true)
      FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
      return isDirectory.boolValue
  }
}
