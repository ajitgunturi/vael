.PHONY: test build-runner coverage analyze clean get

FLUTTER := flutter

get:
	$(FLUTTER) pub get

test:
	$(FLUTTER) test

build-runner:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

coverage:
	$(FLUTTER) test --coverage
	@echo "Coverage report at coverage/lcov.info"

analyze:
	$(FLUTTER) analyze

clean:
	$(FLUTTER) clean
	$(FLUTTER) pub get

format:
	dart format lib test

check: analyze test
	@echo "All checks passed."
