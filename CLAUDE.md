# Repository rules for Claude Code

## Never write to git history or state

Claude must never run any git command that commits, or otherwise mutates, the
repository's history or refs in this project. This includes, but is not limited to:

- `git commit` (including `--amend`)
- `git merge`, `git rebase` (interactive or not), `git cherry-pick`
- `git reset` (soft/mixed/hard), `git revert`
- Squashing, or any other history rewrite
- `git push` / `git push --force`
- `git branch -d`/`-D`, `git tag` (create or delete)
- `git stash` (creating, popping, or dropping — including as a side effect of a script)

This holds even if the user has approved similar actions earlier in the session, even
during multi-step tasks that would normally end with a commit (e.g. finishing a
branch, executing a plan), and even if asked to do "the usual" or to finish the
workflow. Read-only git commands (`status`, `diff`, `log`, `show`, `blame`, etc.) are
fine.

If a task seems to require one of the above, stop and tell the user what you'd run and
why, and let them run it (or explicitly and unambiguously re-authorize it for that
specific action, in that specific message).
