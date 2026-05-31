package internal_tool
import (
	"tool/cli"
//		"tool/os"
	"tool/exec"
		"tool/file"
)
import S "strings"
import Sc "strconv"
import Tu "github.com/jakub-borusewicz/jacues/tools:tool_utils"

command: {
	publish: {
		version_file_name: "version"
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
		commit: exec.Run & Tu.#shell & {
			_dep: write_to_version_file.contents
			expression: "git add * && git commit -m 'version \(bumped_version.version_string)'"
			stdout: string
		}
		run_publish: exec.Run & Tu.#shell & {
			_dep: commit.stdout
			expression: "cue mod publish \(bumped_version.version_string)"
			stdout: string
		}
		push: exec.Run & Tu.#shell & {
			expression: "git push"
		}
		print: cli.Print & {
			text: "Published version \(bumped_version.version_string). Publish output: \(run_publish.stdout)"
		}
	}
	test: {
		print: cli.Print & {
			text: "lol2"
		}
	}
}

#get_semver_from_raw: {
	raw: string
	array: S.Split(S.TrimPrefix(S.TrimSpace(raw), "v"), ".")
	semver: #SemVer & {
		major: Sc.Atoi(array[0])
		minor: Sc.Atoi(array[1])
		patch: Sc.Atoi(array[2])
	}
}

#SemVer: {
	major: int
	minor: int
	patch: int
	version_string: "v\(major).\(minor).\(patch)"
}