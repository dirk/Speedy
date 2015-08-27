import Foundation
import Nimble

@objc class SpecBox {
  let spec: Spec

  init(_ aSpec: Spec) {
    spec = aSpec
  }
}

private enum SpecStatus {
  case Unknown
  case Passed
  case Failed
}

class SpecRunner: NSObject {
  let specs: [Spec]
  var onlyContainingName: String?

  // Status of a spec after it's run
  private var specStatus: SpecStatus = .Unknown

  private let threadingManager: SThreading

  init(_ specs: [Spec]) {
    self.specs = specs
    self.threadingManager = SThreading()
  }

  func run() {
    var hasFailure = false

    println("Running \(specs.count) specs:")

    for spec in specs {
      specStatus = .Unknown

      let block = { () -> () in
        self.runSpec(SpecBox(spec))
      }

      let timeout: NSTimeInterval = 2; // 2 seconds in the future
      let timeoutDate = NSDate(timeIntervalSinceNow: timeout)

      let didntTimeout = threadingManager.runBlockOnThread(block,
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

  func prepareForSpec(spec: Spec) {
    // Silence assertions on this thread
    RSilentAssertionHandler.setup()

    let className = getClassNameOfObject(spec as! AnyObject)

    SpeedySetCurrentGroup(Group(className))

    specStatus = .Passed
  }

  @objc func runSpec(specBox: SpecBox) {
    let spec = specBox.spec

    prepareForSpec(spec)

    // Process the definitions
    spec.spec()

    // Current group will be initialized by #prepareForSpec as a group with
    // the name of the spec's class.
    runGroup(currentGroup, indent: 0)
  }

  func runGroup(group: Group, indent: Int) {
    let i = " ".repeat(indent * 2)

    println("\(i)  \(group.name)")

    for hook in group.beforeAllHooks { hook.block() }

    for child in group.children {
      let i = "\(i)  "

      for hook in group.beforeEachHooks { hook.block() }

      switch child {
      case let .ChildExample(example):
        var exception: NSException! = nil

        if let name = self.onlyContainingName {
          if example.name.rangeOfString(name) == nil {
            continue
          }
        }

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

      for hook in group.afterEachHooks { hook.block() }

    }// for child in children

    for hook in group.afterAllHooks { hook.block() }

  }// runGroup
}

public func testSpecs(specs: [Spec]) {
  NimbleAssertionHandler = NimblePlainAssertionHandler()

  CommandLineRunner(specs).run()
}
