public struct Task {
  
  private var task: (_ workingDirectory: inout String) -> Result<Void, TaskError>
  
  public init(task: @escaping (_ workingDirectory: inout String) -> Result<Void, TaskError>) {
    self.task = task
  }
  
  public init(_ commandBuilder: @escaping () -> Command) {
    self.task = { workingDirectory in
      let command = commandBuilder()
      command.setWorkingDirectoryIfEmpty(workingDirectory)
      command.bindStandardOutput(to: consoleStandardOutputData)
      command.bindStandardError(to: consoleStandardErrorData)
      return command.runSync().mapError { .commandError($0) }
    }
  }

  internal func execute(in workingDirectory: inout String) -> Result<Void, TaskError> {
    task(&workingDirectory)
  }
}

public enum TaskError: Error {
  case invalidDirectory
  case commandError(CommandError)
}
