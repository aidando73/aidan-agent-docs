---
name: sync-agent-docs
description: Sync agent-docs repo to the fireworks repo
disable-model-invocation: true
---

**Important:** `agent-docs/` is a **separate git repo**. Commit from inside it.

1. First commit any changes that have been made under agent-docs/:

```bash
cd agent-docs

git status
git add AGENTS.md AGENTS_DEBUG.md AGENTS_FETCH_PR_DIFFS.md AGENTS_HALLUCINATE.md README.md scripts/ user_rules/ user_skills/
git commit -m "Update agent-docs"
git push
```

2. Then sync the agent-docs repo to the fireworks repo (run from fireworks root):

```bash
cd "$FIREWORKS_DIR"
source ~/.bashrc && gh api repos/aidando73/agent-docs/contents/scripts/setup.sh --jq '.content' | base64 -d | bash
```
