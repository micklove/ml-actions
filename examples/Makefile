.PHONY: scan

scan: ## Run Hawkeye against the current directory
	echo $(CURDIR)
	docker run \
	  --rm \
	  -v $(CURDIR):/target \
	  hawkeyesec/scanner-cli:latest \
	  -a
