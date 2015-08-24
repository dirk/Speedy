import Foundation

class CommandLineRunner {
  let specs: [Spec]

  init(_ specs: [Spec]) {
    self.specs = specs
  }

  func runSpecs() {
    let specRunner = SpecRunner(specs)

    specRunner.run()
  }
}
