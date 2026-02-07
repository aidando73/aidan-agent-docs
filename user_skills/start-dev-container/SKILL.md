---
name: start-dev-container
description: Run the dev server automated setup script
disable-model-invocation: true
---

1. Check if GitHub CLI is already authenticated:

```bash
gh auth status
```

2. If NOT authenticated (the command above failed), run:

```bash
gh auth login -s user
```

3. Fetch and run the setup script:

```bash
gh api repos/fw-ai/fireworks/contents/serving/dev/setup_devserver.sh?ref=main \
  --jq '.content' | base64 -d > /tmp/setup_devserver.sh && \
  bash /tmp/setup_devserver.sh
```
