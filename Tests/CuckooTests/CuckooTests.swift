import XCTest
import Foundation
import Cuckoo

final class CuckooTests: XCTestCase {
  
  func testExample() {
    Workflow(variables: ["pi": 3.14]) { // define workflow with custom variables available to Tasks inside
      Task.printWorkingDirectory() // we can use predefined Tasks
      Task { Command("ls") } // or create own Tasks if needed - here with external command
      Task { Command("ls", standardOutputBinding: consoleStandardOutputData) } // Task sets Command streams (in/out/err) if not set manually, but you can use those
      Task { Command("pwd", workingDirectory: "/usr/bin") } // override working directory for single command
      Task { // you can also create tasks that are constructed from more than one command
        Command("echo", arguments: ["Hello swift!"])
        Command("cat", standardInputBinding: { write in // you can set custom std in for commands and even bind those between commands
          write("Hello streams".data(using:. utf8)!)
          write(Data()) // you have to end it with empty data
        })
      }
      Task { variables in // Tasks does not need to use commands, those can be plain swift with access to workflow variables
        variables.answer = 42 // all variables are dynamic and casted to requested types if needed
        let unsafePi: Double = variables.pi // if types don't match script might crash
        let safePi: Double? = variables.pi // you can use optionals to avoid instant crash and handle missing variables
        consoleStandardOutput("\(safePi == unsafePi)")
        let missing: Double? = variables.missing // it won't crash if you ask for optional value
        assert(missing == nil) // just returns nil if there is no value or type does not match requested
        // let crashing: Double = variables.crashing // it would crash if executed
        return .success
      }
      Task { variables in // all variables are passed between tasks in same workflow
        consoleStandardOutput(variables.answer) // each variable can be automatically converted to String
        let missingButString: String = variables.undefined // convertion to String don't crash
        assert(missingButString == "") // you get description of value (from CustomStringConvertible if able) or empty string
        variables.workingDirectory = "~/Documents" // there is a special variable `workingDirectory` which controls current working directory for executed Tasks and is used by wrapped Commands
        return .success
      }
      Task { Command("pwd") } // prints "~/Documents"
      Task {
        Command("ls", standardOutputBinding: fileOutputData(filePath: "~/Downloads/Cuckoo.txt")) // you can easily use file output if needed
      }
    }.execute() // and at the end execute it waiting for result
    // if you specify `workingDirectory` variable for Workflow it will run at specified path or in current one if not provided
  }
}
