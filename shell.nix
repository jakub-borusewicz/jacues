{
  pkgs ? import <nixpkgs> { },
}:
let
  mkFakeCli = import (pkgs.fetchFromGitHub {
    owner = "jakub-borusewicz";
    repo = "fake-cli";
    rev = "v0.0.1";
    hash = "sha256-wHJ+Xqh1iNFILuvwjv003rwRTtSV4v9ULLey9f+d8bg=";
  }) { inherit pkgs; };

  real-cue = pkgs.cue;
  fake-cue = mkFakeCli {
    name = "cue";
    realPackage = real-cue;
    passthroughWhen = ''! { [ "$1" = "export" ] || { [ "$1" = "mod" ] && [ "$2" = "publish" ]; }; }'';
  };
  fake-git = mkFakeCli { name = "git"; };
  bats-with-libs = pkgs.bats.withLibraries (p: [ p.bats-support p.bats-assert ]);
in
{
  default = pkgs.mkShell {
    packages = [ real-cue bats-with-libs ];
  };
  testFake = pkgs.mkShell {
    packages = [ fake-cue real-cue fake-git bats-with-libs pkgs.jq ];
  };
}
