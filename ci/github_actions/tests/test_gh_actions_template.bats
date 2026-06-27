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
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
EOF
}
