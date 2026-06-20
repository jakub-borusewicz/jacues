

publish:
    cue cmd publish

convert_to_cue file:
    cue import {{file}}

test:
    nix-shell --run "bats ci/github_actions/tests/test_gh_actions_template.bats"