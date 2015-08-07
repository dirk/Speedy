SWIFTC=swiftc -sdk $(shell xcrun --show-sdk-path)

build/Exceptions.o: Speedy/Support/Exceptions.m
	mkdir -p build
	clang -c $^ -o $@

.PHONY: clean

clean:
	rm build/*
