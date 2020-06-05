import XCTest
import Foundation
import Cuckoo

final class CuckooTests: XCTestCase {
  
  func testExample() {
    Workflow(workingDirectory: "~/Documents") { // define workflow with working directory or use current one
      Task.printWorkingDirectory() // we can use predefined tasks
      Task { Command("ls") } // or create own tasks if needed - here with external command
      Task.setWorkingDirectory(to: "~/") // internal tasks does not need to use commands, those can be plain swift
      Task { Command("ls", standardOutputBinding: consoleStandardOutputData) } // set custom std out, both out and err is set by by task to console output if not set manually
      Task { Command("pwd", workingDirectory: "/usr/bin") } // override working directory for single command
      Task { // you can also create tasks that are constructed from more than one command
        Command("echo", arguments: ["Hello swift!"])
        Command("pwd")
      }
    }.execute() // and execute it waiting for result
  }
}
