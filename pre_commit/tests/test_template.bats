setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
}

semi_default_fields=("args" "env" "files" "exclude" "types" "types_or" "exclude_types")

_cue_value_for_field() {
  local field="$1" val="${2:-some_value}"
  case "$field" in
    args|types|types_or|exclude_types) echo "[\"${val}\"]" ;;
    env)                               echo "{KEY: \"${val}\"}" ;;
    files|exclude)                     echo "\"${val}\"" ;;
  esac
}

_assert_hook_field_excluded() {
  local field="$1"
  run bats_pipe echo 'package pre_commit_template, hook: #Hook & {id: "test"}' \| cue export --out yaml -e hook pre_commit/template.cue -
  assert_success
  refute_output --partial "${field}:"
}

for field_name in "${semi_default_fields[@]}"; do
  bats_test_function --description "test_($field_name)_field_excluded_when_not_set" -- \
    _assert_hook_field_excluded "$field_name"
done


_assert_field_included_if_default_value_set() {
  local field="$1"
  local cue_value; cue_value="$(_cue_value_for_field "$field")"
  run bats_pipe echo "package pre_commit_template, hook: #Hook & {id: \"test\", _${field}: ${cue_value}}" \| cue export --out yaml -e hook pre_commit/template.cue -
  assert_success
  assert_output --partial "${field}:"
}

for field_name in "${semi_default_fields[@]}"; do
  bats_test_function --description "test_($field_name)_field_included_if_default_value_version_set" -- \
    _assert_field_included_if_default_value_set "$field_name"
done


_assert_explicit_field_overrides_default() {
  local field="$1"
  local default_cue_value; default_cue_value="$(_cue_value_for_field "$field" "default_val")"
  local override_cue_value; override_cue_value="$(_cue_value_for_field "$field" "override_val")"
  run bats_pipe echo "package pre_commit_template, hook: #Hook & {id: \"test\", _${field}: ${default_cue_value}, ${field}: ${override_cue_value}}" \| cue export --out yaml -e hook pre_commit/template.cue -
  assert_success
  refute_output --partial "default_val"
  assert_output --partial "override_val"
}

for field_name in "${semi_default_fields[@]}"; do
  bats_test_function --description "test_($field_name)_explicit_field_overrides_default" -- \
    _assert_explicit_field_overrides_default "$field_name"
done
