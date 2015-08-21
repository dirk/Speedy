import Nimble

class SpeedySpec: Spec {
  func spec() {
    describe("Group") {
      describe("having a current group") {
        it("should allow defining an Example") {
          let original = getCurrentGroup()
          let testGroup = Group("a group")
          expect(testGroup.name).to(equal("a group"))

          setCurrentGroup(testGroup)

          var exampleRan = false

          it("a child") {
            exampleRan = true
          }

          expect(testGroup.children.count).to(equal(1))

          let child: AnyObject = testGroup.children[0].value()
          expect(child.dynamicType === Example.self).to(beTrue())

          let childExample = child as! Example
          expect(childExample.name).to(equal("a child"))

          childExample.block()
          expect(exampleRan).to(beTrue())

          // Restore the original after we're done
          setCurrentGroup(original)
        }
      }
    }
  }
}
