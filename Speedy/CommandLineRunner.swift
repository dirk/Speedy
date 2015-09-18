import Foundation

class CommandLineRunner {
  let specs: [Spec]
  var options = SpecOptions()

  init(_ specs: [Spec]) {
    self.specs = specs
  }

  func run() {
    let executable = Process.arguments[0]
    let args = [String](Process.arguments[1..<Process.arguments.count])

    let help: Bool = args.contains("-h") || args.contains("--help")
    let containingName = findParameter(args, short: "-n", long: "--name")

    if help {
      return printHelp(executable)
    } else if let name = containingName {
      options.onlyContainingName = name
    }

    runSpecs()
  }// run()

  func findParameter(arguments: [String], _ name: String) -> String? {
    if let index = arguments.indexOf(name) {
      return arguments[index + 1]
    } else {
      return nil
    }
  }

  func findParameter(arguments: [String],
                     short: String,
                     long: String) -> String?
  {
    if let index = arguments.indexOf(short) {
      return arguments[index + 1]
    } else if let index = arguments.indexOf(long) {
      return arguments[index + 1]
    } else {
      return nil
    }
  }

  func runSpecs() {
    let specRunner = SpecRunner(specs, options: options)
    specRunner.run()
  }

  private func printHelp(executable: String) {
    print("Usage: \(executable) [-h]")
    print("")
    print("Options:")
    print("  -h, --help         Print this help and exit")
    print("  -n, --name STRING  Only run examples whose name contains string")
    print("")
  }
}
