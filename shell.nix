{
  pkgs ? import <nixpkgs> { },
}:
let
  mkFakeCli = import ./nix/fake-cli.nix { inherit pkgs; };

  real-cue = pkgs.cue;
  fake-cue = mkFakeCli {
    name = "cue";
    realPackage = real-cue;
    interceptWhen = ''[ "$1" = "export" ] || { [ "$1" = "mod" ] && [ "$2" = "publish" ]; }'';
  };
  fake-git = mkFakeCli { name = "git"; };
  bats-with-libs = pkgs.bats.withLibraries (p: [ p.bats-support p.bats-assert ]);
in
{
  default = pkgs.mkShell {
    packages = [ real-cue bats-with-libs ];
  };
  testFake = pkgs.mkShell {
    packages = [ fake-cue real-cue fake-git bats-with-libs ];
  };
}
