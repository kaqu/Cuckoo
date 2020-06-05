import class Foundation.NSFileManager.FileHandle
import struct Foundation.NSData.Data

extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}

fileprivate var standardOutput = FileHandle.standardOutput
fileprivate var standardError = FileHandle.standardError

public let consoleStandardOutput: (String) -> Void = { _ = print($0, to: &standardOutput) }
public let consoleStandardOutputData: (Data) -> Void = { _ = print(String(data: $0, encoding: .utf8) ?? "", to: &standardOutput) }
public let consoleStandardError: (String) -> Void = { _ = print($0, to: &standardError) }
public let consoleStandardErrorData: (Data) -> Void = { _ = print(String(data: $0, encoding: .utf8) ?? "", to: &standardError) }
