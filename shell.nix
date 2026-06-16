{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    (pkgs.bats.withLibraries (p: [ p.bats-support p.bats-assert ]))
  ];

}
