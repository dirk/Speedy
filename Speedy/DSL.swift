import Foundation

// DSL support ---------------------------------------------------------------

var currentGroup: Group! = nil

public func SpeedySetCurrentGroup(group: Group) {
  currentGroup = group
}
public func SpeedyGetCurrentGroup() -> Group {
  return currentGroup
}

// Actual DSL ----------------------------------------------------------------

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

public func beforeEach(block: () -> ()) {
  currentGroup.addHook(Hook(.BeforeEach, block))
}

public func afterEach(block: () -> ()) {
  currentGroup.addHook(Hook(.AfterEach, block))
}

public func beforeAll(block: () -> ()) {
  currentGroup.addHook(Hook(.BeforeAll, block))
}

public func afterAll(block: () -> ()) {
  currentGroup.addHook(Hook(.AfterAll, block))
}
