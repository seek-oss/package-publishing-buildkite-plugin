#!/usr/bin/env bats

load "$BATS_PATH/load.bash"
teardown() {
  rm -f .npmrc
  unset BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_TOKEN
  unset BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_REGISTRY
  unset BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_WORKDIR

  rm -fr yarn.lock package-lock.json
}


@test "creates a npmrc file with default registry path and token" {
  export BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_TOKEN='abc123'

  run "${PWD}/hooks/command"

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//registry.npmjs.org/:_authToken=abc123'
}


@test "creates a npmrc file with supplied registry path and token" {
  export BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_TOKEN='abc123'
  export BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_REGISTRY='//myprivateregistry.org/'

  run "${PWD}/hooks/command"

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" "${BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_REGISTRY}:_authToken=${BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_TOKEN}"
}


@test "the command fails if none of the fields are not set" {
  run "${PWD}/hooks/command"

  assert_failure
  refute [ -e '.npmrc' ]
}

@test "it invokes yarn if yarn.lock is present" {
  export BUILDKITE_PLUGIN_PACKAGE_PUBLISHING_TOKEN='abc123'

  cp __fixtures__/yarn.lock __fixtures__/package.json .

  run "${PWD}/hooks/command"

  assert_success
  # assert_output "yarning"
}