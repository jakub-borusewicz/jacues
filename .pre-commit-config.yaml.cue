import pre_commit "github.com/jakub-borusewicz/jacues/pre_commit:pre_commit_template"

pre_commit
#project_type: "cue_module"

#cue_auto_export_hook: {
	files: """
		(?x)^(\\.github/workflows/main.yaml.cue | \\.pre-commit-config.yaml.cue)$
		"""
}
