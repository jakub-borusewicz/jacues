package github_actions_definitions
import GA "cue.dev/x/githubactions"


steps_by_name: [Key=string]: GA.#Step
steps_by_name: {
	checkout: {
		uses: "actions/checkout@v3"
		with: {
			"fetch-depth": 0
		}
	}
	setup_just: {
		uses: "extractions/setup-just@v4"
		with: {"just-version": "1.51.0"}
	}
}
