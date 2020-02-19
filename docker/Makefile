.DEFAULT_GOAL := help
.PHONY:

# Get service name from docker-compoose.yaml, convert to json, and get the first key
DOCKER_COMPOSE_SERVICE_NAME:=$(shell cfn-flip docker-compose.yaml | jq -r ".services | keys[0]")
DOCKER_COMPOSE_IMAGE_NAME:=$(shell cfn-flip docker-compose.yaml | jq -r '.services."$(DOCKER_COMPOSE_SERVICE_NAME)".image')
DOCKER_WORKDIR:=/target

SAML2_AWS_CURRENT_VERSION:=2.22.0
SAML2AWS_ZIP=saml2aws_$(SAML2_AWS_CURRENT_VERSION)_linux_amd64.tar.gz
SAML2_AWS_URL=https://github.com/Versent/saml2aws/releases/download/v$(SAML2_AWS_CURRENT_VERSION)/$(SAML2AWS_ZIP)
SAML2_AWS_DIRECTORY_PATH=~/.local/bin
SAML2_AWS_BIN_PATH=$(SAML2_AWS_DIRECTORY_PATH)/saml2aws
SAML2_AWS_MIN_SESSION_DURATION=900

include ../lib/dev-tools.mk

saml2aws-install:
	wget $(SAML2_AWS_URL)
	mkdir -p $(SAML2_AWS_DIRECTORY_PATH)
	tar -xzvf saml2aws_${SAML2_AWS_CURRENT_VERSION}_linux_amd64.tar.gz -C $(SAML2_AWS_DIRECTORY_PATH)
	rm $(SAML2AWS_ZIP)
	chmod u+x $(SAML2_AWS_BIN_PATH)

# make saml2aws-configure IDP_URL=blah USERNAME=blah
saml2aws-configure:
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


rebuild: ## Rebuild the image, stop any existing one.
	docker-compose stop
	docker-compose build
	docker-compose up -d

up:
	docker-compose up -d

start:
	docker-compose start

shell: up
	docker-compose exec $(DOCKER_COMPOSE_SERVICE_NAME) bash

docker-gen: ## Generate the command for an adhoc instance, at the current folder
	@printf "\nRun the following command:\n"
	@echo 'docker run --rm -v ${PWD}:$(DOCKER_WORKDIR) -it $(DOCKER_COMPOSE_IMAGE_NAME) bash'
	@echo 'docker run --rm -v ${PWD}:/target -it $(DOCKER_COMPOSE_IMAGE_NAME) bash'
	@echo alias ub=\'docker run -it --rm -v \$${PWD}:$(DOCKER_WORKDIR) --workdir $(DOCKER_WORKDIR) $(DOCKER_COMPOSE_IMAGE_NAME)\' \$$*

