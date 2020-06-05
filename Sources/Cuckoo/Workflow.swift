import class Foundation.NSTask.Process
import class Foundation.NSFileManager.FileManager

public struct Workflow {
  
  public var workingDirectory: String
  
  public var tasks: Array<Task>
  
  public init(
    workingDirectory: String = FileManager.default.currentDirectoryPath,
    @WorkflowBuilder tasks: () -> Array<Task>
  ) {
    assert(
      !workingDirectory.isEmpty
      && FileManager.default.directoryExists(atPath: workingDirectory),
      "Invalid working directory: \(workingDirectory)"
    )
    self.workingDirectory = workingDirectory
    self.tasks = tasks()
  }
  
  public init(
    workingDirectory: String = FileManager.default.currentDirectoryPath,
    @WorkflowBuilder task: () -> Task
  ) {
    self.workingDirectory = workingDirectory
    self.tasks = [task()]
  }
  
  @discardableResult public func execute() -> Result<Void, WorkflowError> {
    var workingDirectory = self.workingDirectory
    for task in tasks {
      if case let .failure(error) = task.execute(in: &workingDirectory) {
        return .failure(.taskError(error))
      } else {
        continue
      }
    }
    return .success(())
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
