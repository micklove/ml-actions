
# HELP - will output the help for each task
help: ## This help.
	@grep -E -h "^[a-zA-Z_-]+:.*?## " $(MAKEFILE_LIST) \
	  | sort \
	  | awk -v width=22 'BEGIN {FS = ":.*?## "} {printf "\033[36m%-*s\033[0m %s\n", width, $$1, $$2}'

dump: ## Dump any interesting env vars and other context
	@echo MY_ENV=[$(MY_ENV)]
	@echo ENV_CI=[$(ENV_CI)]
	@echo SAML2_AWS_URL=[$(SAML2_AWS_URL)]
	@echo DOCKER_COMPOSE_SERVICE_NAME=[$(DOCKER_COMPOSE_SERVICE_NAME)]
	@echo DOCKER_COMPOSE_SERVICE_NAME=[$(DOCKER_COMPOSE_SERVICE_NAME)]
	@echo MAKEFILE_LIST=[$(MAKEFILE_LIST)]

##
## Create a build manifest file, so that we can quickly see:
## Just supply a variable, BUILD_MANIFEST_VARS, in your main Makefile
## e.g. BUILD_MANIFEST_VARS:=CURRENT_USER GIT_BRANCH GIT_COMMIT GIT_COMMIT_LINK GIT_COMMITER etc...
dump-manifest-vars:
	$(foreach V, $(sort $(BUILD_MANIFEST_VARS)),$(info $V=$($V)))

clean-manifest: ## Clean up any existing manifest file
	@-rm artifacts/manifest/manifest.txt

artifacts/manifest/manifest.txt: clean-manifest ## Create a build manifest file, e.g. make artifacts/manifest/manifest.txt
	@mkdir -p `dirname $@`
	@$(MAKE) --quiet dump-manifest-vars > $@
	@cat $@
