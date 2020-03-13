DEFAULT_HEADER_WIDTH:=120
DEFAULT_HEADER_FG:=32
DEFAULT_HEADER_CHAR:==

## Dumps a prettified version of the variable e.g. GIT_BRANCH   - master, see "dump" target below
## TO use - $(call pretty_var, GIT_BRANCH, $(GIT_BRANCH) )
define pretty_var
	@echo $(1) $(2) $(origin 1) | awk -v width=39 '{printf "  \033[33m%-*s\033[0m - %-*s \033[34m%s\033[0m\n", width, $$1, (width + 25), $$2, $$3}'
endef

## Print header row, with n chars, and a bold heading
## e.g.
##    ***************************************************
##    | 32 - Foo Bar
##    #**************************************************
##
## Color details on https://misc.flogisoft.com/bash/tip_colors_and_formatting
##
define print_header
	@$(eval HEADER_WIDTH:=$(1))
	@$(eval HEADER_MSG:=$(2))
	@$(eval HEADER_CHAR:=$(3))
	@$(eval HEADER_FG:=$(4))
	@printf "\e[$(HEADER_FG)m%0.s$(HEADER_CHAR)\e[0m" {1..$(HEADER_WIDTH)}
	@printf "\n"
	@printf "\e[1;$(HEADER_FG)m| %s \e[0m" $(HEADER_MSG)
	@printf "\n"
	@printf "\e[$(HEADER_FG)m%0.s$(HEADER_CHAR)\e[0m" {1..$(HEADER_WIDTH)}
	@echo ""
endef

test-header:
	$(call print_header, $(DEFAULT_HEADER_WIDTH),'HELLO',$(DEFAULT_HEADER_CHAR),30)
	$(call print_header, $(DEFAULT_HEADER_WIDTH),"HELLO",$(DEFAULT_HEADER_CHAR),31)
	$(call print_header, 50,"32 - Hello World","*",32)
	$(call print_header, $(DEFAULT_HEADER_WIDTH),"33 - Hello World",$(DEFAULT_HEADER_CHAR),33)
	$(call print_header, $(DEFAULT_HEADER_WIDTH),"34 - Hello World",$(DEFAULT_HEADER_CHAR),34)
	$(call print_header, $(DEFAULT_HEADER_WIDTH),"35 - Hello World",$(DEFAULT_HEADER_CHAR),35)
	$(call print_header, $(DEFAULT_HEADER_WIDTH),"36 - Hello World",$(DEFAULT_HEADER_CHAR),36)

# Dump all vars, based on example in gnu make book
get-debug-vars: ## Dump vars, in plain text (nb: - using ! for delimiting the output)
	$(foreach V, $(sort $(.VARIABLES)), $(if $(filter-out environment% default automatic,$(origin $V)),$(info $V=$($V) !$(value $V))))

dump-debug: ## Dump all vars, for debugging. Similar to printvars, but easier to read.
	@$(shell $(MAKE) get-debug-vars > vars.txt)
	@awk 'BEGIN{FS="[=!]"} {printf " \033[33m%-36s\033[0m = \033[32m%-65s\033[0m \033[35m%s\033[0m\n", $$1, $$2, $$3}' vars.txt
	@-rm vars.txt
	@echo GIT_BRANCH=$(GIT_BRANCH)

# See https://www.cmcrossroads.com/article/dumping-every-makefile-variable
.PHONY: printvars
printvars:  ## Print ALL environment variables, use only for debugging.
	@$(foreach V,$(sort $(.VARIABLES)), $(if $(filter-out environment% default automatic,$(origin $V)),$(warning $V=$($V) ($(value $V)))))

dump: dump-debug
