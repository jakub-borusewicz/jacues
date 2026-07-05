package dry_tools

import "strings"

// Drop-in for exec.Run with a dry-run mode.
Run: {
	dry: bool | *false

	// mirror exec.Run's schema
	cmd:    string | [...string]
	dir?:   string
	env: [string]: string | [...string]
	stdout:      *null | string | bytes
	stderr:      *null | string | bytes
	stdin:       *null | string | bytes
	success:     bool
	mustSucceed: bool | *true

	_cmdStr: string
	if (cmd & string) != _|_ {_cmdStr: cmd}
	if (cmd & [...string]) != _|_ {_cmdStr: strings.Join(cmd, " ")}

	if !dry {
		$id: "tool/exec.Run"
	}
	if dry {
		$id:  "tool/cli.Print"
		text: "DRY: would run: \(_cmdStr)"

		// fake the outputs so dependent tasks still become runnable
		if (stdout & string) != _|_ {stdout: ""}
		success: true
	}
}