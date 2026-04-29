.PHONY: check generate

check:
	./scripts/check-env.sh

generate:
	xcodegen generate
