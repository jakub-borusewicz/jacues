# Shared helpers for CUE tool bats tests. See .claude/skills/testing-cue.
#
# CUE tools are tested by wiring the reusable `#commands.*` definition from
# tools/tool_utils.cue into a throwaway "*_tool.cue" file, rather than depending on
# whether/how internal_tool.cue happens to expose it as a command. That keeps the
# test valid for a definition meant to be imported and wired up by other projects.

# Creates a temp dir (inside the repo, so self-imports of this module resolve) with
# a single "test_tool.cue" file containing the CUE given on stdin. Prints the
# directory path on stdout; caller is responsible for `rm -rf`'ing it in teardown.
#
# Usage:
#   TOOL_DIR="$(create_tool_test_dir <<'EOF'
#   package some_test
#   import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"
#   command: some_command: Tu.#commands.some_command & { ... }
#   EOF
#   )"
create_tool_test_dir() {
  local dir
  dir="$(mktemp -d "${BATS_TEST_DIRNAME}/tmp_tool_test.XXXXXX")"
  cat > "$dir/test_tool.cue"
  echo "$dir"
}
