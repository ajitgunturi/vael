.PHONY: test build-runner coverage analyze clean get setup format check bootstrap run-macos run-ios run-android

FLUTTER := flutter

# Load .env if it exists (for build-time dart-defines)
ifneq (,$(wildcard .env))
  include .env
  export
endif

get:
	$(FLUTTER) pub get

bootstrap:
	@echo "Generating platform config files from .env..."
	@./scripts/bootstrap.sh

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
	@if [ -f .env ]; then ./scripts/bootstrap.sh; else echo "NOTE: No .env file. Copy .env.example to .env and run 'make bootstrap'"; fi
	@echo "Done. Git hooks active from .githooks/"

# ─── Platform run targets ────────────────────────────────────────────────────

run-macos:
	$(FLUTTER) run -d macos --dart-define=GOOGLE_CLIENT_ID_MACOS=$(GOOGLE_CLIENT_ID_MACOS) --dart-define=GOOGLE_CLIENT_SECRET_MACOS=$(GOOGLE_CLIENT_SECRET_MACOS)

run-ios:
	$(FLUTTER) run -d iPhone

run-android:
	$(FLUTTER) run -d android
