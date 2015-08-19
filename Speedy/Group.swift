public class Example {
  let name: String
  let block: () -> ()

  init(_ name: String, _ block: () -> ()) {
    self.name  = name
    self.block = block
  }
}


public class Group {

  enum Child {
    case ChildGroup(Group)
    case ChildExample(Example)

    func value() -> AnyObject {
      switch self {
      case let .ChildGroup(group): return group
      case let .ChildExample(example): return example
      }
    }
  }

  let name: String
  var children = [Child]()
  var parent: Group? = nil

  var currentIndex: Int = 0

  init(_ name: String) {
    self.name = name
  }

  func addChild(child: AnyObject) {
    switch child {
    case let group as Group:
      children.append(Child.ChildGroup(group))
    case let example as Example:
      children.append(Child.ChildExample(example))
    default:
      assert(false, "Unreachable!")
    }
  }
}
