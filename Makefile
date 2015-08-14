SWIFTC=swiftc -sdk $(shell xcrun --show-sdk-path)

all: build/Exceptions.o build/Threading.o build/Support.h

build/Support.h: Speedy/Support/*.h
	cat $^ > $@

build/Exceptions.o: Speedy/Support/Exceptions.m
	mkdir -p build
	clang -c $^ -o $@

build/Threading.o: Speedy/Support/Threading.m
	mkdir -p build
	clang -c $^ -o $@

.PHONY: clean

clean:
	rm build/*
