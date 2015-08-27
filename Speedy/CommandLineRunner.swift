import Foundation

class CommandLineRunner {
  let specs: [Spec]

  init(_ specs: [Spec]) {
    self.specs = specs
  }

  func run() {
    let executable = Process.arguments[0]
    var args = [String](Process.arguments[1..<Process.arguments.count])

    let help: Bool = contains(args, "-h") || contains(args, "--help")
    let matchingNameShort = findParameter(args, "-n")
    let matchingNameLong  = findParameter(args, "--name")

    if help {
      return printHelp(executable)

    } else if let name = matchingNameShort {
      runSpecs(matchingName: name)
    } else if let name = matchingNameLong {
      runSpecs(matchingName: name)
    } else {
      runSpecs(matchingName: nil)
    }
  }// run()

  func findParameter(arguments: [String], _ name: String) -> String? {
    if let index = find(arguments, name) {
      return arguments[index + 1]
    } else {
      return nil
    }
  }

  func runSpecs(#matchingName: String?) {
    let specRunner = SpecRunner(specs)
    specRunner.onlyContainingName = matchingName
    specRunner.run()
  }

  private func printHelp(executable: String) {
    println("Usage: \(executable) [-h]")
    println("")
    println("Options:")
    println("  -h, --help         Print this help and exit")
    println("  -n, --name STRING  Only run specs whose fully qualified name contains")
    println("                     the given string")
    println("")
  }
}
