# Speedy

Standalone Swift BDD framework; write specs without the need for Xcode or XCTest.

Currently Speedy depends on the [Roost] build tool and [Nimble] assertion framework.

[Roost]: https://github.com/dirk/Roost
[Nimble]: https://github.com/Quick/Nimble

## Setup and running

You'll need Roost built in the parent directory, see [its repository](https://github.com/dirk/Roost) for instructions on downloading and building Roost.

```bash
git clone https://github.com/dirk/Speedy.git
# Fetch the dependencies
cd Speedy/vendor; carthage bootstrap --platform mac; cd ..
# Use Roost to build Speedy
../Roost/bin/roost build
# Then build Speedy's own tests
../Roost/bin/roost test
# And finally run the tests!
bin/test-speedy
```

## License

Licensed under the 3-clause BSD license. See [LICENSE](LICENSE) for details.
