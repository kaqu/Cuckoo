import class Foundation.NSTask.Process
import class Foundation.NSFileManager.FileManager

public struct Workflow {
  
  public var variables: Variables
  public var tasks: Array<Task>
  
  public init(
    variables: Variables = [:],
    @WorkflowBuilder task: () -> Task
  ) {
    self.variables = variables
    self.tasks = [task()]
    guard (self.variables.workingDirectory as String).isEmpty else { return }
    self.variables.workingDirectory = FileManager.default.currentDirectoryPath
  }
  
  public init(
    variables: Variables = [:],
    @WorkflowBuilder tasks: () -> Array<Task>
  ) {
    self.variables = variables
    self.tasks = tasks()
    guard (self.variables.workingDirectory as String).isEmpty else { return }
    self.variables.workingDirectory = FileManager.default.currentDirectoryPath
  }
  
  @discardableResult
  public func execute() -> Result<Void, WorkflowError> {
    var variables = self.variables
    for task in tasks {
      if case let .failure(error) = task.execute(with: &variables) {
        return .failure(.taskError(error))
      } else {
        continue
      }
    }
    return .success
  }
}

public enum WorkflowError: Error {
  case taskError(TaskError)
}

@_functionBuilder
public enum WorkflowBuilder {
  
  public static func buildBlock(
    _ task: Task
  ) -> Task {
    task
  }
  
  public static func buildBlock(
    _ tasks: Task...
  ) -> Array<Task> {
    tasks
  }
}
