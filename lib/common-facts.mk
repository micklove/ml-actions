PROJECT_ROOT:=$(shell git rev-parse --show-toplevel)

GIT_ORIGIN_URL=$(shell git remote get-url origin)
GIT_COMMIT:=$(shell git rev-parse --short --verify HEAD)
GIT_COMMIT_LINK:=$(shell echo $(GIT_ORIGIN_URL) | sed 's/.git$$//g')/commit/$(GIT_COMMIT)
GIT_COMMITER:=$(shell git show -s --format='%ae' $(GIT_COMMIT))
GIT_OWNER:=$(shell echo $(GIT_ORIGIN_URL) | xargs dirname | xargs basename)
GIT_REPO:=$(shell echo $(GIT_ORIGIN_URL) | xargs basename | sed 's/.git//g')
CURRENT_USER:=$(shell whoami | sed 's/.*\///g')
BUILD_TIMESTAMP:=$(shell date '+%Y-%m-%d-%H-%M-%S')

# Will be populated by the Release event, e.g. {{ github.event.commitish }}
GIT_COMMITISH=
# nb: Note the lack of : on GIT_BRANCH, as it may be changed later.
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD | sed "s*/*-*g")
