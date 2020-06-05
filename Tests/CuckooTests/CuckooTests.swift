import XCTest
import Foundation
@testable import Cuckoo

final class CuckooTests: XCTestCase {
  
  func testExample() {
    Workflow { // define workflow
      Task.printWorkingDirectory() // we can use predefined tasks
      Task { Command("ls") } // or create own tasks if needed - here with external command
      Task.setWorkingDirectory(to: "~/") // internal tasks does not need to use commands
      Task { Command("ls", standardOutputBinding: consoleStandardOutputData) } // set std out, both out and err is set by default by task to console if not set manually
      Task { Command("ls", workingDirectory: "~/Documents") } // override working directory locally
    }.execute() // and execute it waiting for result
  }
}
