---
description: Sync agent-docs repo to the fireworks repo
---

Run this command:

```bash
(source ~/.bashrc && gh api repos/aidando73/agent-docs/contents/scripts/setup.sh --jq '.content' | base64 -d | bash)
```
