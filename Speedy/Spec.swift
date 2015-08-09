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

private enum SpecStatus {
  case Unknown
  case Passed
  case Failed
}


let SpecRunning = 1
let SpecDone    = 2

private var currentGroup: Group! = nil

class SpecRunner {
  let specs: [Spec]

  // Locking while a spec is running on a subthread
  var lock: NSConditionLock!
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
      lock = NSConditionLock(condition: SpecRunning)

      let thread = NSThread(target: self, selector: "runSpec:", object: (spec as! AnyObject))
      thread.start()

      let timeout: NSTimeInterval = 2; // 2 seconds in the future
      let timeoutDate = NSDate(timeIntervalSinceNow: timeout)

      let didntTimeout = lock.lockWhenCondition(SpecDone, beforeDate: timeoutDate)
      let didTimeout   = !didntTimeout

      if didTimeout {
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

      // Unlock it so it can be safely deallocated
      lock.unlock()
    }

    exit(hasFailure ? 1 : 0)
  }

  func prepareForSpec(spec: Spec) {
    // let handler = NimbleAssertionHandlerAdapter(spec)
    // NimbleAssertionHandler = handler

    // Silence assertions on this thread
    RSilentAssertionHandler.setup()

    let className = getClassNameOfObject(spec as! AnyObject)

    currentGroup = Group(className)
    specStatus   = .Passed
  }

  @objc func runSpec(aSpec: AnyObject?) {
    assert(lock.tryLock() == true, "Unable to acquire lock")

    let spec = aSpec as! Spec

    prepareForSpec(spec)

    let topLevelGroup = currentGroup

    // Process the definitions
    spec.spec()

    runGroup(topLevelGroup, indent: 0)

    lock.unlockWithCondition(SpecDone)
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

        let didError = RTryCatch(tryBlock, catchBlock)
        let marker   = (didError ? "✓".colorize(.Green) : "✗".colorize(.Red))

        println("\(i)\(marker) \(example.name)")

        if let e = exception {
          println("\(i)  \(e)")
        }
        
        if didError {
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
