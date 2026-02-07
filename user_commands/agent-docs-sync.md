---
description: Sync agent-docs repo to the fireworks repo
---

1. First commit any changes that have been made under agent-docs/.

```bash
git status
git add -A agent-docs
git commit -m "Update agent-docs"
git push
```

2. Then sync the agent-docs repo to the fireworks repo.

Run this command:

```bash
(source ~/.bashrc && gh api repos/aidando73/agent-docs/contents/scripts/setup.sh --jq '.content' | base64 -d | bash)
```
