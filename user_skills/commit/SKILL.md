---
name: commit
description: Commit changes to git. Use when the user says "commit", "make a commit", or wants to stage and commit their work.
disable-model-invocation: true
---

# Commit Workflow

Guide the user through staging and committing changes.

## Steps

1. **Run `git status`** to see all changed, staged, and untracked files.

2. **`git add` each relevant file individually** — do NOT use `git add .` or `git add -A`.
   - Do **not** include submodule changes (directories that are git submodules).
   - The user may ask for additional files to be included after the initial add.

3. **Run `git diff --cached --stat`** to confirm what will be committed.

4. **Commit** with a descriptive message summarizing the changes:

```bash
git commit -m "$(cat <<'EOF'
<commit message>
EOF
)"
```

5. **Run `git status`** after the commit to verify success.

## Rules

- Never use `git add .` or `git add -A` — always add files explicitly.
- Never include submodule directories in `git add`.
- If unsure which files to include, ask the user.
- Follow the repository's existing commit message style (check `git log --oneline -5` if needed).
