#!/usr/bin/env bash

set -Eeou pipefail

# Given a tag commit, script attempts to work out which branch the commit originated from.
# Useful in Github Actions, when determining which branch the release# was requested on.
# (nb: In github actions, when a "Github release" is triggered, the event will point to HEAD.
#
# nb: The Github "release" event also has a property, called "event.commitish", which provides the branch.

# Ensure we get the correct param count
export USAGE="Usage: $0 <git ref> <sha> [commitish]  e.g. ${0} \"ref/tag/v1.0.1\" abcdefgh master"
: "${1?"${USAGE}"}"
: "${2?"${USAGE}"}"

export GIT_REF="${1}"
export GIT_COMMIT="${2}"
export GIT_COMMITISH="${3}"

if grep -q "refs/tags" <<< "${GIT_REF}"
then
  if [[ -n "${GIT_COMMITISH}" ]]; then
    echo "${GIT_COMMITISH}"
  else
    # If "commitish" is not provided, on the github event. Work out which branch
    # contains this commit. e.g. * master (then strip the '*' prefix)
    git branch --contains "${GIT_COMMIT}" | grep "*" | sed 's#\* ##g'
  fi
else
  git rev-parse --abbrev-ref HEAD | sed "s*/*-*g"
fi
