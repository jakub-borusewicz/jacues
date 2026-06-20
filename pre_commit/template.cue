package pre_commit_template

repos: [...#Repo]
repos: [
	#pre_commit_hooks_repo,
	#sync_pre_commit_deps_repo,
	#meta_repo,
	#local_repo,
]

// TODO create hook for changing the hook and repo definitions, to ensure that
//  some fields can be overwritten and have default (*"value" | string)
//  Probably with something that manipulates ast (treesitter?)
#pre_commit_hooks_repo: #Repo
#pre_commit_hooks_repo: {
	repo: "https://github.com/pre-commit/pre-commit-hooks"
	rev:  "v4.6.0"
	hooks: [
		#end_of_file_fixer_hook,
		#trailing_whitespace_hook,
		#check_added_large_files_hook,
		#check_merge_conflict_hook,
		#detect_private_key_hook,
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

#sync_pre_commit_deps_repo: #Repo
#sync_pre_commit_deps_repo: {
	repo: "https://github.com/mxr/sync-pre-commit-deps"
	rev:  "v0.0.1"
	hooks: [#sync_pre_commit_deps_hook]
}

#sync_pre_commit_deps_hook: #Hook
#sync_pre_commit_deps_hook: {
	id: "sync-pre-commit-deps"
}

#meta_repo: #Repo
#meta_repo: {
	repo: "meta"
	hooks: [
		#check_hooks_apply_hook,
		#check_useless_excludes_hook,
	]
}

#check_hooks_apply_hook: #Hook
#check_hooks_apply_hook: {
	id: "check-hooks-apply"
}

#check_useless_excludes_hook: #Hook
#check_useless_excludes_hook: {
	id: "check-useless-excludes"
}

#local_repo: #Repo
#local_repo: {
	repo: "local"
	hooks: [
		#update_cue_files_hook,
		#format_cue_files_hook,
		#cue_auto_export_hook,
	]
}

#update_cue_files_hook: #HookLocal
#update_cue_files_hook: {
	id:             "update-cue-files"
	name:           "update-cue-files"
	entry:          "cue fix"
	language:       "system"
	pass_filenames: true
}

#format_cue_files_hook: #HookLocal
#format_cue_files_hook: {
	id:             "format-cue-files"
	name:           "format-cue-files"
	entry:          "cue fmt"
	language:       "system"
	pass_filenames: true
	files:          ".*\\.cue$"
}

#cue_auto_export_hook: #HookLocal
#cue_auto_export_hook: {
	id:   "cue-auto-export-tool"
	name: "cue-auto-export-tool"
	entry: """
		bash -c 'for f in "$@"; do cue cmd cue_auto_export -t cue_file_path="$f"; done' --
		"""
	language:       "system"
	pass_filenames: true
	_files: 				".*\\.cue$"
//	files:          *".*\\.cue$" | string
	exclude:        *"(?x)^(config/.* | cue.mod/.* | .*_tool.cue | template/.*)$" | string
}

#Hook: {
	id: string
	name?: string
	entry?: string
	shell?: string
	language?: string
	alias?: string
	_args?: [...string]
	args?: [...string] | *_args

	pass_filenames?: bool

	_env?: {[string]: string}
	_env?: {[string]: string}
	if _env != _|_ {
		env: {[string]: string} | *_env
	}

	_files?: string
	files?: string
	if _files != _|_ {
		files: string | *_files
	}

	_exclude?: string
	exclude?: string
	if _exclude != _|_ {
		exclude: string | *_exclude
	}
}

#HookLocal: #Hook & {
	name: *#Hook.id | string
	entry: string
	language: string
	...
}

#Repo: {
	repo: string
	rev?: string
	hooks: [...#Hook]
	...
}
