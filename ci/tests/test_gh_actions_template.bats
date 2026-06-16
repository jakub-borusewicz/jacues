@test "test lalala" {
  run echo "bla"
  [ "$status" -eq 0 ]
}