public struct Task {
  
  public typealias Closure = (inout Variables) -> Result<Void, TaskError>
  
  private var task: Closure
  
  public init(task: @escaping Closure) {
    self.task = task
  }
  
  public init(@TaskBuilder _ tasksBuilder: @escaping () -> Array<Closure>) {
    self.task = { variables in
      let tasks = tasksBuilder()
      for task in tasks {
        guard case let .failure(error) = task(&variables) else { continue }
        return .failure(error)
      }
      return .success
    }
  }
  
  public init(@TaskBuilder _ commandBuilder: @escaping () -> Command) {
    self.task = { variables in
      let command = commandBuilder()
      command.updateWorkingDirectoryIfNeeded(variables.workingDirectory)
      command.bindStandardOutput(to: consoleStandardOutputData)
      command.bindStandardError(to: consoleStandardErrorData)
      return command.runSync().mapError { .commandError($0) }
    }
  }
  
  public init(@TaskBuilder _ commandsBuilder: @escaping () -> Array<Command>) {
    self.task = { variables in
      let commands = commandsBuilder()
      for command in commands {
        command.updateWorkingDirectoryIfNeeded(variables.workingDirectory)
        command.bindStandardOutput(to: consoleStandardOutputData)
        command.bindStandardError(to: consoleStandardErrorData)
        guard case let .failure(error) = command.runSync() else { continue }
        return .failure(.commandError(error))
      }
      return .success
    }
  }

  internal func execute(with variables: inout Variables) -> Result<Void, TaskError> {
    task(&variables)
  }
}

public enum TaskError: Error {
  case invalidDirectory
  case commandError(CommandError)
  case custom(Error)
}

@_functionBuilder
public enum TaskBuilder {

  public static func buildBlock(
    _ command: Command
  ) -> Command {
    command
  }
  
  public static func buildBlock(
    _ commands: Command...
  ) -> Array<Command> {
    commands
  }
  
  public static func buildBlock(
    _ tasks: (_ workingDirectory: inout String) -> Result<Void, TaskError>...
  ) -> Array<(_ workingDirectory: inout String) -> Result<Void, TaskError>> {
    tasks
  }
}
