package tool_template

import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"

import list "list"

import S "strings"

import "path"

import (
	"tool/cli"
	//		"tool/os"
	"tool/exec"
	//	"tool/file"
)

#command_name_list: ["cue_auto_export"]
#command_name: or(#command_name_list)
#include_commands: [...#include_commands]

command: {
	for v in #command_name_list if list.Contains(#include_commands, v) {"\(v)": #commands[v]}
}

#commands: {
	cue_auto_export: #cue_auto_export
}

#cue_auto_export: {
	file_path:           string
	filepath_without_cue: S.TrimSuffix(file_path, ".cue")
	file_extension:       path.Ext(filepath_without_cue, path.Unix)
	out_param:            extension_out_map[file_extension]
	run_cue_export: exec.Run & Tu.#shell & {
		_dep2: print
		_dep:  file_extension
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
