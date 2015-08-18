import Foundation

/*
import Nimble

class NimbleAssertionHandlerAdapter: AssertionHandler {
  let spec: Spec

  init(_ spec: Spec) {
    self.spec = spec
  }

  func assert(assertion: Bool, message: FailureMessage, location: SourceLocation) {
    if assertion { return }

    println(message.stringValue)
    println("  \(location.description)\n")
  }
}
*/

public protocol Spec {
  func spec()
}

@objc class SpecBox {
  let spec: Spec
  let runner: SpecRunner

  init(_ aSpec: Spec, _ aRunner: SpecRunner) {
    spec = aSpec
    runner = aRunner
  }
}

private enum SpecStatus {
  case Unknown
  case Passed
  case Failed
}


let SpecRunning = 1
let SpecDone    = 2

private var currentGroup: Group! = nil

class SpecRunner: NSObject {
  let specs: [Spec]

  // Status of a spec after it's run
  private var specStatus: SpecStatus = .Unknown


  init(_ specs: [Spec]) {
    self.specs = specs
  }

  func run() {
    var hasFailure = false

    println("Running \(specs.count) specs:")

    for spec in specs {
      specStatus = .Unknown

      let block = {
        self.runSpec(SpecBox(spec, self))
      }

      let timeout: NSTimeInterval = 2; // 2 seconds in the future
      let timeoutDate = NSDate(timeIntervalSinceNow: timeout)

      let didntTimeout = SThreading.runBlockOnThread(block,
                                                     withTimeout:timeoutDate)

      if !didntTimeout {
        println("Spec timed out")
        specStatus = .Failed
      }

      if specStatus == .Failed {
        hasFailure = true
      }
      if specStatus == .Unknown {
        let name = getClassNameOfObject(spec as! AnyObject)
        println("Unknown status of spec: \(name)"); exit(2)
      }
    }

    exit(hasFailure ? 1 : 0)
  }

  func prepareForSpec(spec: Spec, _ runner: SpecRunner) {
    // Silence assertions on this thread
    RSilentAssertionHandler.setup()

    let className = getClassNameOfObject(spec as! AnyObject)

    currentGroup      = Group(className)
    runner.specStatus = .Passed
  }

  @objc func runSpec(specBox: SpecBox) {
    let spec   = specBox.spec
    let runner = specBox.runner

    prepareForSpec(spec, runner)

    // Process the definitions
    spec.spec()

    // Current group will be initialized by #prepareForSpec as a group with
    // the name of the spec's class.
    runGroup(currentGroup, indent: 0)
  }

  func runGroup(group: Group, indent: Int) {
    let i = " ".repeat(indent * 2)

    println("\(i)  \(group.name)")

    for child in group.children {
      let i = "\(i)  "

      switch child {
      case let .ChildExample(example):
        var exception: NSException! = nil

        let tryBlock = {
          example.block()
        }
        let catchBlock = { (caughtException: NSException!) in
          exception = caughtException
        }

        let didPass = RTryCatch(tryBlock, catchBlock)
        let marker  = (didPass ? "✓".colorize(.Green) : "✗".colorize(.Red))

        println("\(i)\(marker) \(example.name)")

        if let e = exception {
          println("\(i)    \(e)")
        }

        if !didPass {
          specStatus = .Failed
        }

      case let .ChildGroup(group):
        runGroup(group, indent: indent + 1)

      }// switch child
    }// for child in children
  }// runGroup
}

public func describe(name: String, definition: () -> ()) {
  let group = Group(name)
  group.parent = currentGroup
  group.parent!.addChild(group)

  currentGroup = group

  definition()

  // Restore parent
  currentGroup = group.parent!
}

public func it(name: String, block: () -> ()) {
  let example = Example(name, block)

  currentGroup.addChild(example)
}

public func testSpecs(specs: [Spec]) {
  RSetupExceptionHandler()

  let runner = SpecRunner(specs)

  runner.run()
}
