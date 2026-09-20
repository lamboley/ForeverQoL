.DEFAULT_GOAL := help

##@ Lint

.PHONY: lint-lua
lint-lua:
	luacheck .

.PHONY: lint
lint: lint-lua

##@ Helpers

.PHONY: help
help:
	Scripts/help.bat
