package tool_utils

import S "strings"

import "path"

import "tool/exec"

#commands: {
	cue_auto_export: #cue_auto_export
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

#shell: {
	expression: string
	cmd: ["sh", "-c", expression]
	...
}
