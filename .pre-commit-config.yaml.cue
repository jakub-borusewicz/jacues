import pre_commit "github.com/jakub-borusewicz/jacues/pre_commit:pre_commit_template"

pre_commit

#cue_auto_export_hook: {
	files: "\\.github/workflows/main.yaml.cue"
	files: """
		(?x)^(\\.github/workflows/main.yaml.cue | \\.pre-commit-config.yaml.cue)$
		"""
}
