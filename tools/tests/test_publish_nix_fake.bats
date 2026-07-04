# bats file_tags=nix_fake

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  export GIT_CALLS_DIR="/tmp/git_calls_$$_${BATS_TEST_NUMBER}"
  export CUE_CALLS_DIR="/tmp/cue_calls_$$_${BATS_TEST_NUMBER}"
  mkdir -p "$GIT_CALLS_DIR" "$CUE_CALLS_DIR"

  # Wire #commands.publish_cue_module up via a throwaway _tool.cue file (cue only
  # loads command definitions from files named "*_tool.cue") instead of relying on
  # internal_tool.cue's "publish" command. This is the same shape a downstream
  # project would use after importing tools:tool_utils, so the test stays valid
  # regardless of whether/how this repo's own tool file wires the command up.
  TOOL_DIR="$(mktemp -d "${BATS_TEST_DIRNAME}/tmp_publish_cue_module_test.XXXXXX")"
  export TOOL_DIR
  VERSION_FILE="version_test_${BATS_TEST_NUMBER}"
  export VERSION_FILE
  printf "v0.0.11\n" > "$TOOL_DIR/$VERSION_FILE"

  cat > "$TOOL_DIR/publish_cue_module_test_tool.cue" <<'EOF'
package publish_cue_module_test

import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"

#version_file: string @tag(version_file)

command: publish: Tu.#commands.publish_cue_module & {version_file_name: #version_file}
EOF
}

teardown() {
  rm -rf "$GIT_CALLS_DIR" "$CUE_CALLS_DIR" "$TOOL_DIR"
}

@test "publish_cue_module updates version file with bumped patch version" {
  run bash -c "cd '$TOOL_DIR' && cue cmd publish -t 'version_file=$VERSION_FILE'"
  assert_success

  run cat "$TOOL_DIR/$VERSION_FILE"
  assert_output "v0.0.12"

  run cat "$GIT_CALLS_DIR/002.txt"
  assert_output "commit -m version v0.0.12"

  run cat "$CUE_CALLS_DIR/001.txt"
  assert_output "mod publish v0.0.12"

  run cat "$GIT_CALLS_DIR/003.txt"
  assert_output "push"
}
