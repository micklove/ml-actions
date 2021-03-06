.PHONY: clean prepare code-quality build unit-test test integration-test security-scan hawkeye-local security help
.DEFAULT_GOAL: help

SHELL=/bin/bash

include ./lib/common-facts.mk
include ./lib/help.mk
include ./lib/debug-tools.mk


# Atlassian build image uses the same base image as the github actions builds, ubuntu-1604,with some extra tools
#  https://hub.docker.com/r/atlassian/default-image/
DOCKER_IMAGE:=atlassian/default-image:2
DOCKER_WORKDIR:=/mypipe

SAML2_AWS_CURRENT_VERSION:=2.22.0
SAML2AWS_ZIP=saml2aws_$(SAML2_AWS_CURRENT_VERSION)_linux_amd64.tar.gz
SAML2_AWS_URL=https://github.com/Versent/saml2aws/releases/download/v$(SAML2_AWS_CURRENT_VERSION)/$(SAML2AWS_ZIP)
SAML2_AWS_DIRECTORY_PATH=~/.local/bin
SAML2_AWS_BIN_PATH=$(SAML2_AWS_DIRECTORY_PATH)/saml2aws
SAML2_AWS_MIN_SESSION_DURATION=900
API_FOLDER=api

BUILD_MANIFEST_VARS:=CURRENT_USER GIT_ORIGIN_URL GIT_BRANCH GIT_COMMIT GIT_COMMIT_LINK GIT_COMMITER GIT_OWNER GIT_REPO ENV_CI ENV_CONTEXT SAML2_AWS_CURRENT_VERSION DOCKER_IMAGE

include ./lib/dev-tools.mk

ci: code-quality build test
cd: ci deploy-all infra-test acceptance-test ui-test

TARGETS:=$(shell jq -r ".scripts | keys | .[]"  package.json | sed 's/:/-/g')
define npm_script_targets
$$(TARGETS):
	npm run $(subst -,:,$(MAKECMDGOALS))

.PHONY: $$(TARGETS)
endef

$(eval $(call npm_script_targets))


clean: ## Remove any redundant local files
	@echo $@
	-rm -rf ./node_modules

saml2aws-install:
	wget $(SAML2_AWS_URL)
	mkdir -p $(SAML2_AWS_DIRECTORY_PATH)
	tar -xzvf saml2aws_${SAML2_AWS_CURRENT_VERSION}_linux_amd64.tar.gz -C $(SAML2_AWS_DIRECTORY_PATH)
	rm $(SAML2AWS_ZIP)
	chmod u+x $(SAML2_AWS_BIN_PATH)

# make saml2aws-configure IDP_URL=blah USERNAME=blah
saml2aws-configure:
	saml2aws --version
	saml2aws configure \
      --url  "$(IDP_URL)" \
      --idp-provider ADFS \
      --username "$(USERNAME)" \
      --mfa Auto \
      --session-duration="$(SAML2_AWS_MIN_SESSION_DURATION)" \
      --skip-prompt
	cat ~/.saml2aws

# make saml2aws-login PASS=BLAHBLAH
saml2aws-login:
	saml2aws login  --password="$(PASS)" --skip-prompt --disable-keychain --force

make sam-build:
	pushd $(API_FOLDER) && sam build

reinstall: clean ## Reinstall any required packages
	@npm install

sam-install: ## Install sam, fail, for local install, if already installed.
	@if [[ -x "`command -v sam`" ]] ; then exit 1; fi
	pip3 install wheel --upgrade
	pip3 install setuptools --upgrade
	pip3 install aws-sam-cli --upgrade

prepare: ## Prepare code, config for ci step
	@echo $@

code-quality: prepare lint security-scan ## Quality - Execute linting , syntax checking, fast security scans
	@echo $@

lint: ## Execute any lint tools
	@echo $@

build: ## Execute the code process
	@echo $@

# =====================   TEST   =====================================

unit-test:  ## Build, then execute unit tests
	@echo $@

integration-test:  ## Execute any integration tests
	@echo $@

infra-test: ## Test any related infra - e.g. server spec
	@echo $@

acceptance-test: ## Test any acceptance tests
	@echo $@

ui-test: ## Test any ui tests
	@echo $@

test: build unit-test integration-test ## Execute all tests
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

TARGET_ENV ?= "UAT"
RELEASE_TITLE ?= "Latest release to $(TARGET_ENV)"
RELEASE_DESC ?= "Add new feature"

create-release: ## Create a github release e.g. make create-release RELEASE_TAG_NAME=v1.7.8 GITHUB_TOKEN=abcdef
	./scripts/create_release.sh \
		$(TARGET_ENV) \
		$(RELEASE_TAG_NAME) \
		$(RELEASE_TITLE) \
		$(RELEASE_DESC) \
		$(GITHUB_TOKEN)

tests: ## Run BATS tests (cd to the folder and run them from there)
	$(call print_header, 50,'BATS Tests',$(DEFAULT_HEADER_CHAR),33)
	@for i in `find . -name "*.bats" -not -path "*/node_modules/*"`; \
	  do printf "\nTesting: $$i\n\n"; \
	    pushd `echo $$i | xargs dirname` >/dev/null && bats $$i;\
	  done
testr:
	@echo blah || echo foo

# https://stackoverflow.com/a/48496716/178808 vs watch -n 5 make tests
watch: scripts/get_git_branch.sh scripts/get_git_branch.test.bats
	while true; do make tests -q || clear; make tests; sleep 5; done

set-git-branch: ## Set the git branch (used for AWS stacks), if we are building from a tag (e.g. Github "Release")
#	@echo GIT_REF: $(GIT_REF)
#	@echo GIT_COMMIT: $(GIT_COMMIT)
#	@echo GIT_COMMITISH: $(GIT_COMMITISH)
	@$(PROJECT_ROOT)/scripts/get_git_branch.sh "$(GIT_REF)" "$(GIT_COMMIT)" "$(GIT_COMMITISH)"

#watch:
#    @while true; do $(MAKE) tests -q || $(MAKE) tests; sleep 0.5; done