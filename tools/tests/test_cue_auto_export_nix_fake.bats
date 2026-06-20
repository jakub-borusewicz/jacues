# bats file_tags=nix_fake

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  export CUE_CALLS_DIR="/tmp/cue_calls_$$_${BATS_TEST_NUMBER}"
  mkdir -p "$CUE_CALLS_DIR"
}

teardown() {
  rm -rf "$CUE_CALLS_DIR"
}

@test "cue_auto_export calls cue export with yaml args for .yaml.cue file" {
  run cue cmd cue_auto_export -t "cue_file_path=/tmp/test.yaml.cue"
  assert_success
  run cat "$CUE_CALLS_DIR/001.txt"
  assert_output "export /tmp/test.yaml.cue --out yaml --outfile /tmp/test.yaml --force"
}

@test "cue_auto_export calls cue export with json args for .json.cue file" {
  run cue cmd cue_auto_export -t "cue_file_path=/tmp/test.json.cue"
  assert_success
  run cat "$CUE_CALLS_DIR/001.txt"
  assert_output "export /tmp/test.json.cue --out json --outfile /tmp/test.json --force"
}
