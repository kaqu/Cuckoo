import class Foundation.NSTask.Process
import class Foundation.Pipe
import class Foundation.FileHandle
import struct Foundation.NSData.Data
import struct Foundation.NSURL.URL
import class Foundation.NSLock.NSConditionLock
import class Foundation.NSFileManager.FileManager

public final class Command {
  
  public var isRunning: Bool { lock.condition == 1 }
  public var isCompleted: Bool { lock.condition == 0 }
  
  private let process: Process
  private let lock: NSConditionLock = NSConditionLock(condition: -1)
  private var hasInheritedWorkingDirectory: Bool
  private var stdInPipe: Pipe? = nil
  private var stdOutPipe: Pipe? = nil
  private var stdErrPipe: Pipe? = nil
  
  public init(
    _ command: String,
    arguments: Array<String> = [],
    commandSearchPath: String? = nil,
    workingDirectory: String? = nil,
    standardInputBinding: ((@escaping (Data) -> Void) -> Void)? = nil,
    standardOutputBinding: ((Data) -> Void)? = nil,
    standardErrorBinding: ((Data) -> Void)? = nil
  ) {
    self.hasInheritedWorkingDirectory = workingDirectory == nil
    self.process = Process.prepare(
      command,
      arguments: arguments,
      workingDirectory: workingDirectory,
      commandSearchPath: commandSearchPath
    )
    if let standardInputBinding = standardInputBinding {
      bindStandardInput(to: standardInputBinding)
    } else { /**/ }
    
    if let standardOutputBinding = standardOutputBinding {
      bindStandardOutput(to: standardOutputBinding)
    } else { /**/ }
    
    if let standardErrorBinding = standardErrorBinding {
      bindStandardError(to: standardErrorBinding)
    } else { /**/ }
  }
  
  @discardableResult
  internal func updateWorkingDirectoryIfNeeded(_ workingDirectory: String) -> Bool {
    guard hasInheritedWorkingDirectory, !workingDirectory.isEmpty else { return false }
    hasInheritedWorkingDirectory = false
    process.currentDirectoryURL = URL(directoryPath: workingDirectory)
    return true
  }
  
  @discardableResult
  public func bindStandardInputWithStandardOutput(of command: Command) -> Bool {
    guard !isCompleted else { return false }
    guard stdInPipe == nil, command.stdOutPipe == nil else { return false }
    let pipe: Pipe = Pipe()
    stdInPipe = pipe
    command.stdOutPipe = pipe
    return true
  }
  
  @discardableResult
  public func bindStandardInputWithStandardError(of command: Command) -> Bool {
    guard !isCompleted else { return false }
    guard stdInPipe == nil, command.stdErrPipe == nil else { return false }
    let pipe: Pipe = Pipe()
    stdInPipe = pipe
    command.stdErrPipe = pipe
    return true
  }
  
  @discardableResult
  public func bindStandardInput(to handler: @escaping (@escaping (Data) -> Void) -> Void) -> Bool {
    guard !isCompleted else { return false }
    guard stdInPipe == nil else { return false }
    let pipe: Pipe = Pipe()
    let fileHandle: FileHandle = pipe.fileHandleForWriting
    handler { data in
      if data.isEmpty {
        fileHandle.closeFile()
      } else {
        fileHandle.write(data)
      }
    }
    stdInPipe = pipe
    return true
  }
  
  @discardableResult
  public func bindStandardOutput(to handler: @escaping (Data) -> Void) -> Bool {
    guard !isCompleted else { return false }
    guard stdOutPipe == nil else { return false }
    let pipe: Pipe = Pipe()
    let fileHandle: FileHandle = pipe.fileHandleForReading
    fileHandle.readabilityHandler = { file in
      let data = file.availableData
      if data.isEmpty {
        fileHandle.closeFile()
      } else {
        handler(data)
      }
    }
    stdOutPipe = pipe
    return true
  }
  
  @discardableResult
  public func bindStandardError(to handler: @escaping (Data) -> Void) -> Bool {
    guard !isCompleted else { return false }
    guard stdErrPipe == nil else { return false }
    let pipe: Pipe = Pipe()
    let fileHandle: FileHandle = pipe.fileHandleForReading
    fileHandle.readabilityHandler = { file in
      let data = file.availableData
      if data.isEmpty {
        fileHandle.closeFile()
      } else {
        handler(data)
      }
    }
    stdErrPipe = pipe
    return true
  }
  
  
  @discardableResult
  public func runSync() -> Result<Void, CommandError> {
    guard lock.tryLock(whenCondition: -1) else { return .failure(.alreadyRunningOrCompleted) }
    lock.unlock(withCondition: 1)
    return Result {
      try process.execute(
        stdInPipe: stdInPipe,
        stdOutPipe: stdOutPipe,
        stdErrPipe: stdErrPipe,
        completion: { [weak self] _ in
          guard let self = self else { return }
          guard self.lock.tryLock(whenCondition: 1) else { fatalError("Unexpected state") }
          self.lock.unlock(withCondition: 0)
        }
      )
      let exitCode = process.waitForExit()
      guard exitCode == 0 else {
        throw CommandError.exitCode(exitCode)
      }
    }.mapError { _ in
      return .executionError
    }
  }
  
  public func runAsync(_ completion: ((Result<Void, CommandError>) -> Void)? = nil) {
    guard lock.tryLock(whenCondition: -1) else { return completion?(.failure(.alreadyRunningOrCompleted)) ?? () }
    lock.unlock(withCondition: 1)
    do {
      try process.execute(
        stdInPipe: stdInPipe,
        stdOutPipe: stdOutPipe,
        stdErrPipe: stdErrPipe,
        completion: { [weak self] exitCode in
          guard let self = self else { return }
          guard self.lock.tryLock(whenCondition: 1) else { fatalError("Unexpected state") }
          self.lock.unlock(withCondition: 0)
          if exitCode == 0 {
            completion?(.success)
          } else {
            completion?(.failure(.exitCode(exitCode)))
          }
        }
      )
    } catch {
      completion?(.failure(.executionError))
    }
  }
}

public enum CommandError: Error {
  case alreadyRunningOrCompleted
  case exitCode(Int32)
  case custom(Error)
  case executionError // TODO
}
