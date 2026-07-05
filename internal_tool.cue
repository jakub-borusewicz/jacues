package internal_tool

import (
	"tool/cli"
//	"tool/exec"
)

import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"
import dry_tools "github.com/jakub-borusewicz/jacues/tools:dry_tools"

dry_run: bool | *false @tag(dry,type=bool)

#cue_file_path: string              @tag(cue_file_path)
#version_file:  string | *"version" @tag(version_file)

command: {
	cue_auto_export: Tu.#commands.cue_auto_export & {file_path: #cue_file_path}
	publish: Tu.#commands.publish_cue_module & {version_file_name: #version_file}
	test: {
		print: cli.Print & {
			text: "lol2"
		}
		print2: dry_tools.Run & {
			dry: dry_run
			cmd: "echo 'lol xd'"
			$after: print
		}
	}
}

//#dry_run: {
//	expression:
//	run: exec
//}