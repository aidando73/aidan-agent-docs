---
description: Make changes under agent-docs/ then commit and push
---

**Important:** `agent-docs/` is a **separate git repo** (not part of the parent fireworks repo). All git commands must run from inside `agent-docs/`.

1. Make the requested changes to files in the `agent-docs/` directory.
   - Do **not** edit or commit anything under `agent-docs/pr_diffs/` (it's generated PR snapshot content).
   - If the user did not specify which changes to make, please ask.
2. `cd` into `agent-docs/`, then run `git status`, stage, commit, and push:

```bash
cd agent-docs

git status

# Stage changed files (excluding generated PR diffs).
git add -A .
git reset pr_diffs/

git commit -m "Update agent-docs"

git push
```
