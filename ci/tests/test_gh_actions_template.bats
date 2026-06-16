setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
}



@test "test export" {
  run cue export --out yaml ci/github_actions_template.cue

  assert_success
  assert_output - <<-'EOF'
jobs:
  trala:
    steps:
      - name: run bats
        run: bats .
EOF
}