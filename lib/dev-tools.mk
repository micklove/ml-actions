
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
	@echo DOCKER_COMPOSE_IMAGE_NAME=[$(DOCKER_COMPOSE_IMAGE_NAME)]
