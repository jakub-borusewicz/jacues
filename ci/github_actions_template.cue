package github_actions_template
import GA "cue.dev/x/githubactions"
//import "list"

#job_types: ["cue_module"]
#job_type: or(#job_type)
#include_jobs: [...#job_type]
#include_jobs: ["cue_module"]
#jobs_by_type: [job_type=string]: GA.#Job
#jobs_by_type: {
	"cue_module": {
		steps: [
			{
				name: "run bats"
				run: "bats ."
			}
		]
	}
}

//jobs: [...GA.#Job]
//jobs: [for j in #job_types  {#jobs_by_type[j]}]
jobs: {
	trala: {
		steps: [
			{
				name: "run bats"
				run: "bats ."
			}
		]
	}
}

//jobs: [for j in #job_types if list.Contains(#include_jobs, j) {#jobs_by_type[j]}]
