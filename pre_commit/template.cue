package pre_commit_template

import pcd "github.com/jakub-borusewicz/jacues/pre_commit:pre_commit_definitions"


repos: [
	pcd.repos_by_name.pre_commit_hooks,
	pcd.repos_by_name.sync_pre_commit_deps,
	pcd.repos_by_name.meta,
	pcd.repos_by_name.local,
	...pcd.#Repo,
]
