public struct Task {
  
  private var task: (_ workingDirectory: inout String) -> Result<Void, TaskError>
  
  public init(task: @escaping (_ workingDirectory: inout String) -> Result<Void, TaskError>) {
    self.task = task
  }
  
  public init(@TaskBuilder _ tasksBuilder: @escaping () -> Array<(_ workingDirectory: inout String) -> Result<Void, TaskError>>) {
    self.task = { workingDirectory in
      let tasks = tasksBuilder()
      for task in tasks {
        guard case let .failure(error) = task(&workingDirectory) else { continue }
        return .failure(error)
      }
      return .success(())
    }
  }
  
  public init(@TaskBuilder _ commandBuilder: @escaping () -> Command) {
    self.task = { workingDirectory in
      let command = commandBuilder()
      command.overrideInheritedWorkingDirectory(workingDirectory)
      command.bindStandardOutput(to: consoleStandardOutputData)
      command.bindStandardError(to: consoleStandardErrorData)
      return command.runSync().mapError { .commandError($0) }
    }
  }
  
  public init(@TaskBuilder _ commandsBuilder: @escaping () -> Array<Command>) {
    // TODO: local workingDirectory for commands?
    // - command can change working directory of its own, do we need to propagate it somehow?
    self.task = { workingDirectory in
      let commands = commandsBuilder()
      for command in commands {
        command.overrideInheritedWorkingDirectory(workingDirectory)
        command.bindStandardOutput(to: consoleStandardOutputData)
        command.bindStandardError(to: consoleStandardErrorData)
        guard case let .failure(error) = command.runSync() else { continue }
        return .failure(.commandError(error))
      }
      return .success(())
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
