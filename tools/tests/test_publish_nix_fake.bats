# bats file_tags=nix_fake

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  export GIT_CALLS_DIR="/tmp/git_calls_$$_${BATS_TEST_NUMBER}"
  export CUE_CALLS_DIR="/tmp/cue_calls_$$_${BATS_TEST_NUMBER}"
  VERSION_FILE="version_test_${BATS_TEST_NUMBER}"
  export VERSION_FILE
  mkdir -p "$GIT_CALLS_DIR" "$CUE_CALLS_DIR"
  printf "v0.0.11\n" > "$VERSION_FILE"
}

teardown() {
  rm -rf "$GIT_CALLS_DIR" "$CUE_CALLS_DIR"
  rm -f "$VERSION_FILE"
}

@test "publish updates version file with bumped patch version" {
  run cue cmd publish -t "version_file=$VERSION_FILE"
  assert_success
  run cat "$VERSION_FILE"
  assert_output "v0.0.12"
}

@test "publish calls git commit with bumped version" {
  run cue cmd publish -t "version_file=$VERSION_FILE"
  assert_success
  run cat "$GIT_CALLS_DIR/002.txt"
  assert_output "commit -m version v0.0.12"
}

@test "publish calls cue mod publish with bumped version" {
  run cue cmd publish -t "version_file=$VERSION_FILE"
  assert_success
  run cat "$CUE_CALLS_DIR/001.txt"
  assert_output "mod publish v0.0.12"
}

@test "publish calls git push after publishing" {
  run cue cmd publish -t "version_file=$VERSION_FILE"
  assert_success
  run cat "$GIT_CALLS_DIR/003.txt"
  assert_output "push"
}
