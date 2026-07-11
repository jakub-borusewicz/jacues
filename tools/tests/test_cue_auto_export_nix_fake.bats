# bats file_tags=nix_fake

load 'test_helper'

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  export CUE_CALLS_DIR="/tmp/cue_calls_$$_${BATS_TEST_NUMBER}"
  mkdir -p "$CUE_CALLS_DIR"

  TOOL_DIR="$(create_tool_test_dir <<'EOF'
package cue_auto_export_test

import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"

#cue_file_path: string @tag(cue_file_path)

command: cue_auto_export: Tu.#commands.cue_auto_export & {file_path: #cue_file_path}
EOF
)"
  export TOOL_DIR
}

teardown() {
  rm -rf "$CUE_CALLS_DIR" "$TOOL_DIR"
}

@test "cue_auto_export calls cue export with yaml args for .yaml.cue file" {
  run bash -c "cd '$TOOL_DIR' && cue cmd cue_auto_export -t 'cue_file_path=/tmp/test.yaml.cue'"
  assert_success
  run jq -c .argv "$CUE_CALLS_DIR/001.json"
  assert_output '["export","/tmp/test.yaml.cue","--out","yaml","--outfile","/tmp/test.yaml","--force"]'
}

@test "cue_auto_export calls cue export with json args for .json.cue file" {
  run bash -c "cd '$TOOL_DIR' && cue cmd cue_auto_export -t 'cue_file_path=/tmp/test.json.cue'"
  assert_success
  run jq -c .argv "$CUE_CALLS_DIR/001.json"
  assert_output '["export","/tmp/test.json.cue","--out","json","--outfile","/tmp/test.json","--force"]'
}

@test "cue_auto_export fails with status 1 when file_path does not end with .cue" {
  run bash -c "cd '$TOOL_DIR' && cue cmd cue_auto_export -t 'cue_file_path=/tmp/test.json'"
  assert_failure
  assert_output --partial 'file_path: invalid value "/tmp/test.json"'
}
