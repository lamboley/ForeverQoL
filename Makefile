##@ Lint

.PHONY: lint-lua
lint: lint-lua
	luacheck .

##@ Helpers

.PHONY: clean
clean: ## Clean up build and test artifacts.
	scripts/clean.sh