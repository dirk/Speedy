import Nimble

func emptyCVaListPointer() -> CVaListPointer {
  let pointer = UnsafeMutablePointer<Void>()

  return CVaListPointer(_fromUnsafeMutablePointer: pointer)
}

class NimblePlainAssertionHandler: AssertionHandler {
  func assert(assertion: Bool, message: FailureMessage, location: SourceLocation) {
    if !assertion {
      let format = "\(message.stringValue) (\(location.description))"

      NSException.raise("NimbleAssertionFail",
                        format: format,
                        arguments: emptyCVaListPointer())
    }
  }
}
