import Foundation

class CommandLineRunner {
  let specs: [Spec]

  init(_ specs: [Spec]) {
    self.specs = specs
  }

  func run() {
    let executable = Process.arguments[0]
    var args = Process.arguments[1..<Process.arguments.count]

    let help: Bool = contains(args, "-h") || contains(args, "--help")

    if help {
      return printHelp(executable)

    } else {
      runSpecs()
    }
  }// run()

  func runSpecs() {
    let specRunner = SpecRunner(specs)

    specRunner.run()
  }

  private func printHelp(executable: String) {
    println("Usage: \(executable) [-h]")
    println("")
    println("Options:")
    println("  -h --help   Print this help and exit")
    println("")
  }
}
