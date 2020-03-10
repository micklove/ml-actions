#!/usr/bin/env bash

set -Eeou pipefail
# Create a github release, on master

# Ensure we get the correct param count
export USAGE="Usage: $0 <env> <tag> <release title> <release desc> <github token>  e.g. ${0} uat \"v1.1.0\" \"my tag title\" \"env=uat add new stuff\" abcefdummytokenghijk"
: "${1?"${USAGE}"}"
: "${2?"${USAGE}"}"
: "${3?"${USAGE}"}"
: "${4?"${USAGE}"}"
: "${5?"${USAGE}"}"

export TARGET_ENV=$(tr [:upper:] [:lower:] <<< ${1})
export RELEASE_TAG_NAME="${2}"
export RELEASE_TITLE="${3}"
export RELEASE_DESC="${4}"
export GITHUB_TOKEN="${5}"

echo "TARGET_ENV=${TARGET_ENV}"

# Make sure the env is ok
if ! grep -q -E -i "uat|prod" <<< "${TARGET_ENV}"
then
  printf "Env must be either uat or prod\n" && exit 1
fi

export TARGET_BRANCH=master
export GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD | sed "s*/*-*g")
export GIT_COMMIT=$(git rev-parse --short --verify HEAD)
export GIT_COMMITER=$(git show -s --format='%ae' "${GIT_COMMIT}")
export GIT_OWNER=$(git remote get-url origin | sed 's#.*github.com/##' | xargs dirname)
export GIT_REPO=$(git remote get-url origin | sed 's#.*github.com/##' | xargs basename | sed 's#.git##g')
export CURRENT_USER=$(whoami | sed "s/[^[:alpha:]]//g")
export RELEASE_DESCRIPTION="env=${TARGET_ENV} released-by=${CURRENT_USER} - [${RELEASE_DESC}]"

if [[ "${TARGET_BRANCH}" != "${GIT_BRANCH}" ]]; then
  printf "\n\nWarning: current branch, ${GIT_BRANCH}, is not ${TARGET_BRANCH}, tag will be created on ${TARGET_BRANCH}\n\n"
fi

export SCHEME="https"
export HOST="api.github.com"
export BASE_ENDPOINT="${SCHEME}://${HOST}/repos/${GIT_OWNER}/${GIT_REPO}"
echo "BASE_ENDPOINT=[${BASE_ENDPOINT}]"
export RELEASES_RESOURCE="releases"
export RELEASES_ENDPOINT="${BASE_ENDPOINT}/${RELEASES_RESOURCE}"
# See https://developer.github.com/v3/repos/releases/#create-a-release

## Get latest Tag
export LATEST=
LATEST=$(curl -s -H "Content-Type: application/json" -H "Authorization: token ${GITHUB_TOKEN}" "${RELEASES_ENDPOINT}/latest" | jq -r .tag_name)
echo "Current latest tag=${LATEST}"

## Use a heredoc, to create the release payload (may revisit this, with jq or node solution)
TMP_FILE=./$$.tmp
cat <<- PAYLOAD > "${TMP_FILE}"
{
  "tag_name": "${RELEASE_TAG_NAME}",
  "target_commitish": "${TARGET_BRANCH}",
  "name": "${RELEASE_TITLE}",
  "body": "${RELEASE_DESCRIPTION}",
  "draft": false,
  "prerelease": false
}
PAYLOAD

jq . "${TMP_FILE}"

export RESPONSE=$(
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -d "@${TMP_FILE}" \
  "${RELEASES_ENDPOINT}" \
  -w "\n%{http_code}")

echo "RESPONSE=${RESPONSE}"

# Ensure we got a 201, created, as per the spec
if [[ "$(tail -n 1 <<< "${RESPONSE}")" != "201" ]];
then
  echo "Error ocurred"
  exit 1
fi


rm -rf "${TMP_FILE}"