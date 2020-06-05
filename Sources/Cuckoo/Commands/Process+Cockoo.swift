import class Foundation.NSTask.Process
import class Foundation.NSTask.ProcessInfo
import struct Foundation.NSData.Data
import struct Foundation.NSURL.URL
import class Foundation.Pipe
import class Foundation.FileHandle

internal extension Process {
  
  static func prepare(
    _ command: String,
    arguments: Array<String> = [],
    workingDirectory: String? = nil,
    commandSearchPath: String? = nil
  ) -> Process {
    let process = Process()
    
    process.executableURL = URL(string: "file:///usr/bin/env")
    process.arguments = [command] + arguments
    
    if let workingDirectory = workingDirectory {
      process.currentDirectoryURL = URL(directory: workingDirectory)
    } else { /* use inherited from current process */ }
    
    if let commandSearchPath = commandSearchPath {
      var environment = ProcessInfo.processInfo.environment
      if let path = environment["PATH"] {
        environment["PATH"] = "\(path): \(commandSearchPath)"
      } else {
        environment["PATH"] = commandSearchPath
      }
      process.environment = environment
    } else { /* use inherited from current process */ }
    return process
  }
  
  @discardableResult func waitForExit() -> Int32 {
    waitUntilExit()
    return terminationStatus
  }
  
  func execute(
    stdInPipe: Pipe? = nil,
    stdOutPipe: Pipe? = nil,
    stdErrPipe: Pipe? = nil,
    completion: @escaping (Int32) -> Void = { _ in }
  ) throws {
    if let stdInPipe = stdInPipe {
      standardInput = stdInPipe
    } else {
      standardInput = FileHandle.nullDevice
    }

    if let stdOutPipe = stdOutPipe {
      standardOutput = stdOutPipe
    } else {
      standardOutput = FileHandle.nullDevice
    }
    
    if let stdErrPipe = stdErrPipe {
      standardError = stdErrPipe
    } else {
      standardError = FileHandle.nullDevice
    }
    
    terminationHandler = { process in
      stdInPipe?.fileHandleForWriting.closeFile()
      stdOutPipe?.fileHandleForReading.closeFile()
      stdErrPipe?.fileHandleForReading.closeFile()
      completion(process.terminationStatus)
    }

    try run()
  }
}
