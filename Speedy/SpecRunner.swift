import Foundation
import Nimble

@objc class SpecBox: NSObject {
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

struct SpecOptions {
  var onlyContainingName: String?

  init() {
    onlyContainingName = nil
  }
}

class SpecRunner: NSObject {
  let specs: [Spec]
  var options: SpecOptions

  // Status of a spec after it's run
  private var specStatus: SpecStatus = .Unknown

  private let threadingManager: SThreading

  init(_ specs: [Spec], options: SpecOptions) {
    self.specs = specs
    self.options = options
    self.threadingManager = SThreading()
  }

  func run() {
    var hasFailure = false

    print("Running \(specs.count) specs:")

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
        print("Spec timed out")
        specStatus = .Failed
      }

      if specStatus == .Failed {
        hasFailure = true
      }
      if specStatus == .Unknown {
        let name = getClassNameOfObject(spec as! AnyObject)
        print("Unknown status of spec: \(name)"); exit(2)
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
    let indentRepeat = Repeat(count: indent * 2, repeatedValue: " ")
    let i = indentRepeat.joinWithSeparator("")

    print("\(i)  \(group.name)")

    for hook in group.beforeAllHooks { hook.block() }

    for child in group.children {
      let i = "\(i)  "

      for hook in group.beforeEachHooks { hook.block() }

      switch child {
      case let .ChildExample(example):
        var exception: NSException! = nil

        if let name = self.options.onlyContainingName {
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

        print("\(i)\(marker) \(example.name)")

        if let e = exception {
          print("\(i)    \(e)")
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
