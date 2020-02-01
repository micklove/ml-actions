.PHONY: clean prepare code-quality build unit-test test integration-test security-scan hawkeye-local security help

# Atlassian build image uses the same base image as the github actions builds, ubuntu-1604,with some extra tools
#  https://hub.docker.com/r/atlassian/default-image/
DOCKER_IMAGE:=atlassian/default-image:2
DOCKER_WORKDIR:=/mypipe

ci: clean code-quality build test
cd: ci deploy-all infra-test acceptance-test ui-test


clean: ## Remove any redundant local files
	@echo $@

reinstall: clean ## Reinstall any required packages
	-rm -rf ./node_modules
	@npm install

prepare: ## Prepare code, config for ci step
	@echo $@

code-quality: prepare lint security-scan ## Quality - Execute linting , syntax checking, fast security scans
	@echo $@

lint: ## Execute any lint tools
	@echo $@

build: ## Execute the code process
	@echo $@

# =====================   TEST   =====================================

unit-test: build code-quality ## Build, then execute unit tests
	@echo $@

integration-test: build code-quality ## Execute any integration tests
	@echo $@

infra-test: ## Test any related infra - e.g. server spec
	@echo $@

acceptance-test: ## Test any acceptance tests
	@echo $@

ui-test: ## Test any ui tests
	@echo $@

test: unit-test integration-test ## Execute all tests
	@echo $@

# ==================================================================

security-scan: hawkeye-local detect-secrets
	@echo $@

# See https://github.com/Yelp/detect-secrets
detect-secrets: ## Execute the detect-secrets tool - used for finding high-entropy strings
	@echo $@

deploy-api: ## Deploy the UI code
	@echo $@

deploy-ui: ## Deploy the API code
	@echo $@

deploy-all: deploy-api deploy-ui
	@echo $@

hawkeye-scan: ## Execute the Hawkeye security scan against the current directory (using the latest docker image)
	@docker run \
	  --rm \
	  -v $(CURDIR):/target \
	  hawkeyesec/scanner-cli:latest \
	  -a

hawkeye-local:  ## Execute the Hawkeye security scan against the current directory
	@echo $@
	@npx hawkeye scan -a --target .

docker-%:  ## Run the target within make within a docker container -- e.g. `make docker-help`
	docker run \
		--rm \
		-it \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $(CURDIR):$(DOCKER_WORKDIR) \
		--workdir $(DOCKER_WORKDIR) \
		--entrypoint make \
		$(DOCKER_IMAGE) \
		"$(subst docker-,,$@)"
# sharing the AWS folder?
# 		--volume $(HOME)/.aws:/root/.aws \

bash:  ## Run a bash shell - (e.g. run with make docker-bash for an interactive shell in the container
	/bin/bash

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)



