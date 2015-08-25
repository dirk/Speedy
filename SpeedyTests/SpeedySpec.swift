import Nimble

class SpeedySpec: Spec {
  func spec() {
    describe("Group") {
      describe("having a current group") {
        it("should allow defining an Example") {
          let original = SpeedyGetCurrentGroup()
          let testGroup = Group("a group")
          expect(testGroup.name).to(equal("a group"))

          SpeedySetCurrentGroup(testGroup)

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
          SpeedySetCurrentGroup(original)
        }
      }
    }// describe Group

    describe("Hooks") {
      var beforeEachCount = 0
      var afterEachCount  = 0
      var beforeAllCount  = 0
      var afterAllCount   = 0

      describe("having a hooks testing group") {
        beforeEach {
          beforeEachCount += 1
        }
        afterEach {
          afterEachCount += 1
        }
        beforeAll {
          beforeAllCount += 1
        }
        afterAll {
          afterAllCount += 1
        }

        it("will run some hooks") {
          return
        }
      }

      describe("having had a group with hooks") {
        it("should have called the beforeEach the correct number of times") {
          expect(beforeEachCount).to(equal(1))
        }

        it("should have called the afterEach the correct number of times") {
          expect(afterEachCount).to(equal(1))
        }

        it("should have called the beforeAll the correct number of times") {
          expect(beforeAllCount).to(equal(1))
        }

        it("should have called the afterAll the correct number of times") {
          expect(afterAllCount).to(equal(1))
        }
      }
    }// describe Hooks
  }
}
