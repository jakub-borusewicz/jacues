package tool_utils

import S "strings"

import "path"

import Sc "strconv"

import (
	"tool/exec"
	"tool/file"
	"tool/cli"
)

#commands: {
	cue_auto_export:    #cue_auto_export
	publish_cue_module: #publish_cue_module
}

#cue_auto_export: {
	file_path:            string & =~"\\.cue$"
	filepath_without_cue: S.TrimSuffix(file_path, ".cue")
	file_extension:       path.Ext(filepath_without_cue, path.Unix)
	out_param:            extension_out_map[file_extension]
	run_cue_export: exec.Run & #shell & {
		_dep:       file_extension
		expression: "cue export \(file_path) --out \(out_param) --outfile \(filepath_without_cue) --force"
		stdout:     string
	}
}

extension_out_map: {
	".json":      "json"
	".cue":       "cue"
	".yaml":      "yaml"
	".yml":       "yaml"
	".jsonl":     "jsonl"
	".ldjson":    "jsonl"
	".textproto": "textproto"
	".proto":     "proto"
	".go":        "go"
	".txt":       "text"
	"":           "text"
}

#publish_cue_module: {
	version_file_name: string
	version_file_content: file.Read & {
		filename: version_file_name
		contents: string
	}
	get_semver: #get_semver_from_raw & {
		raw: version_file_content.contents
	}
	bumped_version: #SemVer & {
		major: get_semver.semver.major
		minor: get_semver.semver.minor
		patch: get_semver.semver.patch + 1
	}
	write_to_version_file: file.Create & {
		filename: version_file_name
		contents: "\(bumped_version.version_string)\n"
	}
	commit: exec.Run & #shell & {
		_dep:       write_to_version_file.contents
		expression: "git add * && git commit -m 'version \(bumped_version.version_string)'"
		stdout:     string
	}
	run_publish: exec.Run & #shell & {
		_dep:       commit.stdout
		expression: "cue mod publish \(bumped_version.version_string)"
		stdout:     string
	}
	push: exec.Run & #shell & {
		_dep:       run_publish.stdout
		expression: "git push"
	}
	print: cli.Print & {
		text: "Published version \(bumped_version.version_string). Publish output: \(run_publish.stdout)"
	}
}

#publish_copier_template: {}

#shell: {
	expression: string
	cmd: ["sh", "-c", expression]
	...
}

#get_semver_from_raw: {
	raw:   string
	array: S.Split(S.TrimPrefix(S.TrimSpace(raw), "v"), ".")
	semver: #SemVer & {
		major: Sc.Atoi(array[0])
		minor: Sc.Atoi(array[1])
		patch: Sc.Atoi(array[2])
	}
}

#SemVer: {
	major:          int
	minor:          int
	patch:          int
	version_string: "v\(major).\(minor).\(patch)"
}
