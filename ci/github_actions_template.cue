package github_actions_template
import GA "cue.dev/x/githubactions"


#job_type: "cue_module"
#include_jobs: [...#job_type]

#jobs_by_type: [job_type=string]: GA.#Job


jobs: [...GA.#Job]
jobs: []