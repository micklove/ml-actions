#!/usr/bin/env bats

export GIT_REF="refs/tags/v1.2.0"
export COMMIT_FROM_MASTER="88bffa7bbad935a0a1738162d9de9e528680080d"

@test "addition using bcx" {
  result="$(echo 2+2 | bc)"
  [[ "${result}" -eq 4 ]]
}

@test "it should error when git refs is not provided" {
  run get_git_branch.sh
  [[ "${status}" -eq 1 ]]
  grep -i "usage" <<< "${lines[0]}"
}

@test "it should error when the git commit is missing" {
  run get_git_branch.sh "${GIT_REF}"
  [[ "${status}" -eq 1 ]]
  grep -i "usage" <<< "${lines[0]}"
}

@test "it should echo the current branch when not using a tag" {
  expected_branch="$(git rev-parse --abbrev-ref HEAD | sed "s*/*-*g")"
  echo "expected_branch:[${expected_branch}"
  run get_git_branch.sh "ignored" "${COMMIT_FROM_MASTER}" "blah"
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" = "${expected_branch}" ]]
}

@test "it should echo the commitish value if provided and we are using a tag" {
  expected_branch="master"
  run get_git_branch.sh "${GIT_REF}" "${COMMIT_FROM_MASTER}" "master"
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" = "${expected_branch}" ]]
}

@test "it should echo correct branch for the sha if commitish not provided" {
  expected_branch="$(git rev-parse --abbrev-ref HEAD | sed "s*/*-*g")"
  run get_git_branch.sh "${GIT_REF}" "${COMMIT_FROM_MASTER}" "master"
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" = "${expected_branch}" ]]
}

