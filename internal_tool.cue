package internal_tool

import (
	"tool/cli"
)

import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"

#cue_file_path: string              @tag(cue_file_path)
#version_file:  string | *"version" @tag(version_file)

command: {
	cue_auto_export: Tu.#commands.cue_auto_export & {file_path: #cue_file_path}
	publish: Tu.#commands.publish_cue_module & {version_file_name: #version_file}
	test: {
		print: cli.Print & {
			text: "lol2"
		}
	}
}
