---
description: Make changes under agent-docs/ then commit and push
---

1. Make the requested changes to files in the `agent-docs/` directory.
   - Do **not** edit or commit anything under `agent-docs/pr_diffs/` (it’s generated PR snapshot content).
   - If the user did not specify which changes to make, please ask.
2. Run `git status`, then commit the files that were changed, then push:

```bash
git status

# Stage changed files under agent-docs/ (excluding generated PR diffs).
git add -A agent-docs
git reset agent-docs/pr_diffs/

git commit -m "Update agent-docs"

git push
```
