import class Foundation.NSFileManager.FileManager

public extension Task {
  
  static func printWorkingDirectory(to output: @escaping (String) -> Void = consoleStandardOutput) -> Task {
    Task { currentWorkingDirectory in
      output(currentWorkingDirectory)
      return .success(())
    }
  }

  static func setWorkingDirectory(to workingDirectory: String) -> Task {
    Task { currentWorkingDirectory in
      guard
        !workingDirectory.isEmpty,
        FileManager.default.directoryExists(atPath: workingDirectory)
      else { return .failure(.invalidDirectory) }
      currentWorkingDirectory = workingDirectory
      return .success(())
    }
  }
}
