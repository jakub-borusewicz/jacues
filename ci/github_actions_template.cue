package github_actions_template
//import GA "cue.dev/x/githubactions"
import "list"

#job_types_list: ["cue_module"]
#job_type: or(#job_types_list)
#include_jobs: [...#job_type]
//#include_jobs: ["cue_module"]
//#jobs_by_type: [job_type=string]: GA.#Job
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

jobs: {for v in #job_types_list if list.Contains(#include_jobs, v) {"\(v)": #jobs_by_type[v]}}

