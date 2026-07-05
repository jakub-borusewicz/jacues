package dry_tools

import (
	"strings"
	"tool/cli"
	"tool/exec"
)

// Drop-in for exec.Run with a dry-run mode.
//
// cue cmd only recognizes a struct as a task if its $id can be traced back to
// one of the real tool/* packages (see internal/task's isTask check in the cue
// source) - a hand-written `$id: "tool/exec.Run"` field looks right but is
// never picked up. So instead of faking $id, unify with the real exec.Run or
// cli.Print depending on `dry`.
Run: {
	dry: bool | *false
	cmd: string | [...string]

	_cmdStr: string
	if (cmd & string) != _|_ {_cmdStr: cmd}
	if (cmd & [...string]) != _|_ {_cmdStr: strings.Join(cmd, " ")}

	if !dry {
		exec.Run & {cmd: cmd}
	}
	if dry {
		cli.Print & {text: "DRY: would run: \(_cmdStr)"}
	}
}