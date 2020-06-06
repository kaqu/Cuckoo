import class Foundation.NSFileManager.FileManager

public extension Task {
  
  static func printWorkingDirectory(to output: @escaping (String) -> Void = consoleStandardOutput) -> Task {
    Task { variables in
      output(variables.workingDirectory ?? FileManager.default.currentDirectoryPath)
      return .success
    }
  }

  static func setWorkingDirectory(to workingDirectory: String) -> Task {
    Task { variables in
      guard
        !workingDirectory.isEmpty,
        FileManager.default.directoryExists(atPath: workingDirectory)
      else { return .failure(.invalidDirectory) }
      variables.workingDirectory = workingDirectory
      return .success
    }
  }
}
