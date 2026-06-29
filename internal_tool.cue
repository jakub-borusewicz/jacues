package internal_tool

import (
	"tool/cli"
)

import S "strings"

import Sc "strconv"

import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"

#cue_file_path: string              @tag(cue_file_path)
#version_file:  string | *"version" @tag(version_file)

command: {
	cue_auto_export: Tu.#commands.cue_auto_export & {file_path: #cue_file_path}
	publish: Tu.#commands.publish & {version_file_name: #version_file}
	test: {
		print: cli.Print & {
			text: "lol2"
		}
	}
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
