

publish:
    cue cmd publish

convert_to_cue file:
    cue import {{file}}

test:
    nix-shell --run "bats ci/tests/test_gh_actions_template.bats"