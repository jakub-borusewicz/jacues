

publish:
    cue cmd publish

convert_to_cue file:
    cue import {{file}}

pre-commit:
    prek run --all-files

test:
    nix-shell --attr testFake --run "bats --filter-tags 'nix_fake' --recursive ."
    nix-shell --attr default --run "bats --filter-tags '!nix_fake' --recursive ."


debug_cue file expression:
    cue eval {{file}} -e "{{expression}}" --all


mermaid_graph:
    CUE_DEBUG=toolsflow cue cmd test 2>&1 >/dev/null | awk '/^```mermaid$/{buf=""; f=1; next} /^```$/{if(f) last=buf; f=0; next} f{buf=buf $0 "\n"} END{printf "%s", last}' | mermaid-ascii -f -

mermaid_graph_2:
    CUE_DEBUG=toolsflow cue cmd -t dry=true test 2>&1 >/dev/null \
      | awk '/^```mermaid$/{buf=""; f=1; next} /^```$/{if(f) last=buf; f=0; next} f{buf=buf $0 "\n"} END{printf "%s", last}' \
      | mmdc -i - -e png -o - \
      | mpv --image-display-duration=inf --really-quiet -
