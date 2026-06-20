setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
}



@test "test export" {
  run bats_pipe echo 'package github_actions_template,#include_jobs: ["cue_module"]' \| cue export --out yaml ci/github_actions/github_actions_template.cue -

  assert_success
  assert_output - <<-'EOF'
jobs:
  cue_module:
    steps:
      - name: run bats
        run: bats .
EOF
}
