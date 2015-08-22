public class Hook {
  enum Kind {
    case BeforeEach
    case BeforeAll
    case AfterEach
    case AfterAll
  }

  let kind: Kind
  let block: () -> ()

  init(_ kind: Kind, _ block: () -> ()) {
    self.kind  = kind
    self.block = block
  }
}
