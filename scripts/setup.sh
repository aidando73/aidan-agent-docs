#!/bin/bash
set -euo pipefail

# Clone agent-docs repo and install AGENTS_AIDAN.md as a Cursor rule
# Run from the root of the fireworks repo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$REPO_ROOT"

if [ -d "agent-docs" ]; then
    echo "agent-docs/ already exists, pulling latest..."
    git -C agent-docs pull
else
    echo "Cloning agent-docs..."
    git clone https://github.com/aidando73/agent-docs.git agent-docs
fi

mkdir -p .cursor/rules
cp agent-docs/AGENTS_AIDAN.md .cursor/rules/AGENTS_AIDAN.mdc
echo "Copied AGENTS_AIDAN.md to .cursor/rules/AGENTS_AIDAN.mdc"
