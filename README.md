```bash
# Setup
(cd $FIREWORKS_DIR && gh api repos/aidando73/agent-docs/contents/scripts/setup.sh --jq '.content' | base64 -d | bash)
```
