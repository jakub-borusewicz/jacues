package pre_commit_template

import pcd "github.com/jakub-borusewicz/jacues/pre_commit:pre_commit_definitions"

repos: [...#Repo]
repos: [
	#pre_commit_hooks_repo,
	pcd.repos_by_name.sync_pre_commit_deps,
	pcd.repos_by_name.meta,
	pcd.repos_by_name.local,
]


#pre_commit_hooks_repo: #Repo
#pre_commit_hooks_repo: {
		repo: "https://github.com/pre-commit/pre-commit-hooks"
		rev:  "v4.6.0"
		hooks: [
			#end_of_file_fixer_hook,
			#trailing_whitespace_hook,
			#check_added_large_files_hook,
			#check_merge_conflict_hook,
			#detect_private_key_hook
	]
}

#end_of_file_fixer_hook: #Hook
#end_of_file_fixer_hook: {
	id: "end-of-file-fixer"
}

#trailing_whitespace_hook: #Hook
#trailing_whitespace_hook: {
			id: "trailing-whitespace"
}

#check_added_large_files_hook: #Hook
#check_added_large_files_hook: {
	id:        "check-added-large-files"
}

#check_merge_conflict_hook: #Hook
#check_merge_conflict_hook: {
	id:        "check-merge-conflict"
}

#detect_private_key_hook: #Hook
#detect_private_key_hook: {
	id:        "detect-private-key"
}

repos_by_name: {
	pre_commit_hooks: {
		repo: "https://github.com/pre-commit/pre-commit-hooks"
		rev:  "v4.6.0"
		hooks: [{
			id: "end-of-file-fixer"
		}, {
			id: "trailing-whitespace"
		}, {
			id:        "check-added-large-files"
			fail_fast: true
		}, {
			id:        "check-merge-conflict"
			fail_fast: true
		}, {
			id:        "detect-private-key"
			fail_fast: true
		}]
	}
	sync_pre_commit_deps: {
		repo: "https://github.com/mxr/sync-pre-commit-deps"
		rev:  "v0.0.1"
		hooks: [{id: "sync-pre-commit-deps"}]
	}
	meta: {
		repo: "meta"
		hooks: [{
			id: "check-hooks-apply"
		}, {
			id: "check-useless-excludes"
		}]
	}
	local: {
		repo: "local"
		hooks: [{
			id:             "update-cue-files"
			name:           "update-cue-files"
			entry:          "cue fix"
			language:       "system"
			pass_filenames: true
		}, {
			id:             "format-cue-files"
			name:           "format-cue-files"
			entry:          "cue fmt"
			language:       "system"
			pass_filenames: true
			files:          ".*\\.cue$"
		},
		#cue_auto_export_hook
	]}
}


#cue_auto_export_hook: {
	id:   "cue-auto-export-tool"
	name: "cue-auto-export-tool"
	entry: """
		bash -c 'for f in "$@"; do cue cmd cue_auto_export -t cue_file_path="$f"; done' --
		"""
	language:       "system"
	pass_filenames: true
	files:          ".*\\.cue$"
	exclude:        "(?x)^(config/.* | cue.mod/.* | .*_tool.cue | template/.*)$"
}


#Hook: {
	id: string
	...
}

#Repo: {
	repo: string
	rev?: string
	hooks: [...#Hook]
	...
}