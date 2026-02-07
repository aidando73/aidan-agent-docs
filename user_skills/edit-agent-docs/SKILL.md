---
name: edit-agent-docs
description: Make changes under agent-docs/ then commit and push
disable-model-invocation: true
---

**Important:** `agent-docs/` is a **separate git repo** (not part of the parent fireworks repo). All git commands must run from inside `agent-docs/`.

1. Make the requested changes to files in the `agent-docs/` directory.
   - Do **not** edit or commit anything under `agent-docs/pr_diffs/` (it's generated PR snapshot content).
   - If the user did not specify which changes to make, please ask.
2. `cd` into `agent-docs/`, then run `git status`, stage, commit, and push:

```bash
cd agent-docs

git status

# Stage everything except generated content (e.g., do not commit pr_diffs/)
git add <all changed files except generated content>

git commit -m "Update agent-docs"

git push
```

3. After pushing, run the sync to update cursor rules and local copies:

```bash
cd "$FIREWORKS_DIR"
source ~/.bashrc && gh api repos/aidando73/agent-docs/contents/scripts/setup.sh --jq '.content' | base64 -d | bash
```
