
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

