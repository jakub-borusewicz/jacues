---
name: testing-cue
description: Use when writing or running bats tests for this project's CUE code — plain CUE files/definitions/templates (tested via `cue export`, no mocking) or CUE tools/commands in internal_tool.cue and tools/tool_utils.cue that shell out via tool/exec (must always run under mocked git/cue binaries built with nix/fake-cli.nix's mkFakeCli). Also covers running/debugging `just test`, and adding a new mocked CLI fake.
---

# Testing CUE

## Overview

This repo's CUE code is tested with [bats](https://bats-core.readthedocs.io/)
(`bats-support` + `bats-assert`), run inside Nix shells so dependencies are pinned.
There are two kinds of CUE under test, and they are tested completely differently:

| What you're testing | Has side effects? | How | Tag / lane |
|---|---|---|---|
| Plain CUE (structs, definitions, templates) | No | Assert on `cue export` output | none — real lane |
| A CUE **tool** (`command:` in `internal_tool.cue`, built from `tool/exec`/`tool/file` in `tools/tool_utils.cue`) | Yes, by design | Assert on mocked-program call logs | `# bats file_tags=nix_fake` — fake lane |

**The rule: a CUE tool is never tested without mocking every program it runs.**
Tools exist specifically to run `git commit`, `git push`, `cue mod publish`, write files,
etc. — that's the point of a tool, as opposed to a plain CUE value. Running one for real
in a test means actually committing/pushing/publishing from the test suite. There is no
"just try it and see" tier for tools; if it shells out, it runs under fakes, full stop.

Plain CUE (no `tool/exec`) has no side effects to fake, so it's tested the opposite way:
run it for real through `cue export` and assert on the output — optionally unifying in a
small extra CUE snippet (piped in, or via `-t`/`-e`) to exercise a specific branch
without editing the file under test.

## Running tests

```bash
just test
```

Runs both lanes (see `justfile`):

```
nix-shell --attr testFake --run "bats --filter-tags 'nix_fake' --recursive ."
nix-shell --attr default --run "bats --filter-tags '!nix_fake' --recursive ."
```

To iterate on one file without the full suite, drop into the matching shell directly:

```bash
nix-shell --attr testFake --run "bats tools/tests/test_publish_nix_fake.bats"
nix-shell --attr default --run "bats ci/github_actions/tests/test_gh_actions_template.bats"
```

Tests run from the repo root by default — CUE resolves the module from there. Tool
tests instead `cd` into a generated temp directory before running `cue cmd <name>` (see
below), so `<name>` only needs to match a command defined in that temp file, not
anything in `internal_tool.cue`.

## Testing a CUE tool (always mocked)

**Test the reusable `#commands.*` definition in `tools/tool_utils.cue`, not
`internal_tool.cue`'s wiring of it.** `internal_tool.cue` is just one consumer of these
definitions — another project could import this module and wire the same command up
under a different name, with different defaults, or not at all. So instead of running
`cue cmd <name>` against this repo's own `internal_tool.cue`, each fake-lane test
generates its own throwaway `*_tool.cue` file (CUE only loads commands from files named
`*_tool.cue`) that imports `tools:tool_utils` and wires up just the one `#commands.*`
definition under test. That way the test still passes even if `internal_tool.cue`
renames, stops using, or never defined that command.

The shared helper for this lives in `tools/tests/test_helper.bash`:

```bash
create_tool_test_dir() {
  local dir
  dir="$(mktemp -d "${BATS_TEST_DIRNAME}/tmp_tool_test.XXXXXX")"
  cat > "$dir/test_tool.cue"
  echo "$dir"
}
```

It makes a temp dir *inside the repo* (self-imports of `github.com/jakub-borusewicz/jacues/...`
only resolve from somewhere under this module's root — a `/tmp` dir outside the repo
won't work) and writes whatever CUE is piped to it as `test_tool.cue`. Load it with
`load 'test_helper'` near the top of the bats file, build the dir in `setup()` by piping
in a small CUE snippet that wires up just the one command under test, `rm -rf` it in
`teardown()` alongside the other scratch dirs, and run tests as `cd "$TOOL_DIR" && cue
cmd <name> ...`. Full example below. `tmp_tool_test.*` is gitignored as a safety net in
case a crashed run ever leaves one behind.

Fakes are built with `nix/fake-cli.nix`'s `mkFakeCli` function and wired into
`shell.nix`'s `testFake` shell only — never `default`:

```nix
mkFakeCli = import ./nix/fake-cli.nix { inherit pkgs; };

fake-git = mkFakeCli { name = "git"; };

fake-cue = mkFakeCli {
  name = "cue";
  realPackage = real-cue;
  interceptWhen = ''[ "$1" = "export" ] || { [ "$1" = "mod" ] && [ "$2" = "publish" ]; }'';
};
```

`mkFakeCli { name, realPackage ? null, interceptWhen ? "true", ... }` builds a
`writeShellScriptBin` that, whenever `interceptWhen` (a bash condition, default: always)
is true, appends `"$@"` to a new zero-padded file (`001.txt`, `002.txt`, ...) in a
directory named by `<NAME>_CALLS_DIR` (e.g. `GIT_CALLS_DIR`, `CUE_CALLS_DIR`) — letting a
test assert both *that* a call happened and *what arguments* it received, in order,
without running the real command. When `interceptWhen` is false it `exec`s the real
binary via `realPackage` (omit `realPackage` for a tool, like git, that should never run
for real in tests — `interceptWhen` then has nothing to fall through to, so leave it at
the default "always intercept").

A test can also control what the fake returns, via two more env vars the fake reads on
every intercepted call: `<NAME>_MOCK_STDOUT` (literal text to print) and
`<NAME>_MOCK_EXIT_CODE` (defaults to `0`). Set them in `setup()` for a test that needs
the tool under test to see specific output or a failure from the program it shells out
to — e.g. `export CUE_MOCK_EXIT_CODE=1` to make the next `cue` call fail.

**Adding a new tool that shells out to a program:** call `mkFakeCli` for it in
`shell.nix`, add the result to `testFake.packages` only, and pass `realPackage`
+ `interceptWhen` if some of its subcommands need to run for real.

Reference example, `tools/tests/test_publish_nix_fake.bats`:

```bash
# bats file_tags=nix_fake

load 'test_helper'

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  export GIT_CALLS_DIR="/tmp/git_calls_$$_${BATS_TEST_NUMBER}"
  export CUE_CALLS_DIR="/tmp/cue_calls_$$_${BATS_TEST_NUMBER}"
  mkdir -p "$GIT_CALLS_DIR" "$CUE_CALLS_DIR"

  TOOL_DIR="$(create_tool_test_dir <<'EOF'
package publish_cue_module_test

import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"

#version_file: string @tag(version_file)

command: publish: Tu.#commands.publish_cue_module & {version_file_name: #version_file}
EOF
)"
  export TOOL_DIR
  VERSION_FILE="version_test_${BATS_TEST_NUMBER}"
  export VERSION_FILE
  printf "v0.0.11\n" > "$TOOL_DIR/$VERSION_FILE"
}

teardown() {
  rm -rf "$GIT_CALLS_DIR" "$CUE_CALLS_DIR" "$TOOL_DIR"
}

@test "publish_cue_module updates version file with bumped patch version" {
  run bash -c "cd '$TOOL_DIR' && cue cmd publish -t 'version_file=$VERSION_FILE'"
  assert_success

  run cat "$GIT_CALLS_DIR/002.txt"
  assert_output "commit -m version v0.0.12"

  run cat "$CUE_CALLS_DIR/001.txt"
  assert_output "mod publish v0.0.12"
}
```

Key points:
- `# bats file_tags=nix_fake` must be the **first line** of the file — this is what
  routes the file into the `testFake` lane. Filename convention: `test_<tool>_nix_fake.bats`.
- `load 'test_helper'` pulls in `create_tool_test_dir` (see above).
- `setup()`/`teardown()` create and clean up a unique `*_CALLS_DIR` per test
  (`$$_${BATS_TEST_NUMBER}` avoids collisions across parallel/repeated runs), plus the
  `TOOL_DIR` from `create_tool_test_dir` and any scratch files the tool writes to (e.g.
  a fake version file *inside* `TOOL_DIR`) — never point a test at the repo's real
  `version` file.
- Assert call order/content by reading the numbered files in `$*_CALLS_DIR`
  (`001.txt`, `002.txt`, ...), one per invocation of the mocked program.
- Drive the tool the same way a user would, just from `TOOL_DIR`:
  `cd "$TOOL_DIR" && cue cmd <command> -t "<tag>=<value>"`.

## Testing plain CUE (no mocking, no tag)

Plain CUE — templates, definitions, anything without `tool/exec`/`tool/file` — has
nothing to mock. Test it by evaluating it for real with `cue export` and asserting on
output, optionally unifying in extra CUE (piped in, or a field override) to hit a
particular case. See `ci/github_actions/tests/test_gh_actions_template.bats`:

```bash
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
}

@test "test export" {
  run bats_pipe echo 'package github_actions_template,#project_type: "cue_module"' \| cue export --out yaml ci/github_actions/github_actions_template.cue -
  assert_success
  assert_output --partial - <<-'EOF'
jobs:
  test_cue_module:
...
EOF
}
```

`pre_commit/tests/test_template.bats` shows the same idea plus a pattern for generating
one test per case via a bash loop + `bats_test_function`, instead of hand-writing
near-duplicate `@test` blocks — reach for it when the same assertion needs to run over a
list of field names/values.

## Common mistakes

- **Testing a tool without mocking what it shells out to.** If it uses `tool/exec` /
  `tool/file`, it goes in the fake lane — no exceptions, even for a "quick" test. Running
  it in the `default` lane means it actually commits/pushes/publishes.
- Adding a fake binary to `default.packages` in `shell.nix` — that defeats the point of
  the real lane.
- Forgetting the `# bats file_tags=nix_fake` first line — the test silently runs in the
  wrong lane against real binaries.
- Not giving each test its own `*_CALLS_DIR`/scratch file — parallel or repeated test
  runs will clobber each other's recorded calls.
- Asserting on `$CUE_CALLS_DIR/001.txt` etc. without accounting for every call the tool
  makes to that program, including passthrough ones — the fake numbers *all*
  invocations it intercepts, in call order.
- Running `cue cmd <name>` against this repo's own `internal_tool.cue` instead of a
  throwaway `*_tool.cue` file — couples the test to how this repo happens to expose the
  command, which breaks if `internal_tool.cue` renames or drops it, and can't cover a
  `#commands.*` definition this repo never wires up at all.
