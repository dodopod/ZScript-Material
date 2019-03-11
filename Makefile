sources=$(shell find src -type f)
target=material.pk3

test-sources=$(shell find src -type f)
test-target=test.pk3

build/$(target): $(sources)
	7z a -tzip $@ ./src/*

build/$(test-target): $(test-sources)
	7z a -tzip $@ ./test/*

clean:
	rm -r build/*

.PHONY: clean
