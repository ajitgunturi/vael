.PHONY: test build-runner coverage analyze clean get setup format check

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

check: format-check analyze test
	@echo "All checks passed."

format-check:
	dart format --set-exit-if-changed lib test

setup:
	$(FLUTTER) pub get
	git config core.hooksPath .githooks
	@echo "Done. Git hooks active from .githooks/"
