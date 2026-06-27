{
  pkgs ? import <nixpkgs> { },
}:
let
  real-cue = pkgs.cue;
  fake-cue = pkgs.writeShellScriptBin "cue" ''
    if [ "$1" = "export" ]; then
      dir="''${CUE_CALLS_DIR:?CUE_CALLS_DIR must be set}"
      mkdir -p "$dir"
      n=$(find "$dir" -maxdepth 1 -name "*.txt" | wc -l)
      echo "$@" > "$dir/$(printf '%03d' $((n + 1))).txt"
      exit 0
    else
      exec ${real-cue}/bin/cue "$@"
    fi
  '';
  bats-with-libs = pkgs.bats.withLibraries (p: [ p.bats-support p.bats-assert ]);
in
{
  default = pkgs.mkShell {
    packages = [ real-cue bats-with-libs ];
  };
  testFake = pkgs.mkShell {
    packages = [ fake-cue real-cue bats-with-libs ];
  };
}
