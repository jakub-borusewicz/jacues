setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
}

_assert_hook_field_excluded() {
  local field="$1"
  run bats_pipe echo 'package pre_commit_template, hook: #Hook & {id: "test"}' \| cue export --out yaml -e hook pre_commit/template.cue -
  assert_success
  refute_output --partial "${field}:"
}


# TODO add for each field and verify if test is correct (fails if the definition is not valid)
@test "env not included in hook when not set" {
  _assert_hook_field_excluded "env"
}

@test "files not included in hook when not set" {
  _assert_hook_field_excluded "files"
}

@test "exclude not included in hook when not set" {
  _assert_hook_field_excluded "exclude"
}
