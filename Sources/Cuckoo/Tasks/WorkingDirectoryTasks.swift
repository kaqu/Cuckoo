public extension Task {
  
  static func printWorkingDirectory(to output: @escaping (String) -> Void = consoleStandardOutput) -> Task {
    Task { currentWorkingDirectory in
      output(currentWorkingDirectory)
      return .success(())
    }
  }

  static func setWorkingDirectory(to workingDirectory: String) -> Task {
    Task { currentWorkingDirectory in
      guard !workingDirectory.isEmpty else { return .failure(.invalidDirectory)} // TODO: check if is valid dir
      currentWorkingDirectory = workingDirectory
      return .success(())
    }
  }
}
