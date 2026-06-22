

publish:
    cue cmd publish

convert_to_cue file:
    cue import {{file}}

pre-commit:
    prek run --all-files

test:
    nix-shell --attr testFake --run "bats --filter-tags 'nix_fake' --recursive ."
    nix-shell --attr default --run "bats --filter-tags '!nix_fake' --recursive ."
