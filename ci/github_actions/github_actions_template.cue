package github_actions_template

//import GA "cue.dev/x/githubactions"
import "list"

import definitions "github.com/jakub-borusewicz/jacues/ci/github_actions:github_actions_definitions"

#job_types_list: ["cue_module"]
#job_type: or(#job_types_list)

#include_jobs: [...#job_type]
//#include_jobs: ["cue_module"]
//#jobs_by_type: [job_type=string]: GA.#Job

#jobs_by_type: {
	"cue_module": {
		steps: [
			definitions.steps_by_name.checkout,
			{
				name: "run bats"
				run:  "bats ."
			},
		]
	}
}

name: "ci"
on: push: branches: ["**"]
jobs: {for v in #job_types_list if list.Contains(#include_jobs, v) {"\(v)": #jobs_by_type[v]}}
