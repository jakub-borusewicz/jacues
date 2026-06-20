package pre_commit_definitions
//import "list"

//import pre_commit "github.com/jakub-borusewicz/jacues/pre_commit:pre_commit"

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

