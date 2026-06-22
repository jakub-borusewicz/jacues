package github_actions_template

import GA "cue.dev/x/githubactions"

import meta "github.com/jakub-borusewicz/jacues/meta:meta"

#project_type!: meta.#project_type

name: "ci"
on: push: branches: ["**"]
jobs: {
	"test_\(#project_type)": #jobs_by_type[#project_type]
}

#jobs_by_type: {
	"cue_module": {
		steps: [
			#checkout_step,
			#setup_just_step,
			#install_nix_action_step,
			{
				name: "run tests"
				run:  "just test"
			},
		]
	}
}

#checkout_step: GA.#Step
#checkout_step: {
	uses: "actions/checkout@v3"
	with: {
		"fetch-depth": 0
	}
}

#setup_just_step: GA.#Step
#setup_just_step: {
	uses: "extractions/setup-just@v4"
	with: {"just-version": "1.51.0"}
}

#install_nix_action_step: GA.#Step
#install_nix_action_step: {
	uses: "cachix/install-nix-action@v30"
}
