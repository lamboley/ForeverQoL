# Copyright (c) 2026 Lucas Lamboley. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##@ Install

.PHONY: install-scoop
install-scoop:
	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; irm get.scoop.sh | iex

.PHONY: install-psscriptanalyzer
install-psscriptanalyzer: ## Install PSScriptAnalyzer.
	Install-Module -Name PSScriptAnalyzer -Force

.PHONY: install-luacheck
install-luacheck: ## Install luacheck.
	scoop install luacheck

.PHONY: install-stylua
install-stylua: ## Install stylua.
	scoop install stylua

.PHONY: install
install: install-psscriptanalyzer install-luacheck install-stylua ## Install all tools.

##@ Lint

.PHONY: lint-powershell
lint-powershell: ## Run powershell.
	luacheck .

.PHONY: lint-luacheck
lint-luacheck: ## Run luacheck.
	luacheck .

.PHONY: lint-stylua
lint-stylua: ## Run stylua.
	stylua --check .

.PHONY: lint
lint: lint-powershell lint-luacheck lint-stylua ## Run all lint.
