#!/bin/bash
set -euo pipefail

# Clone agent-docs repo and install AGENTS_AIDAN.md as a Cursor rule
# Run from the root of the fireworks repo

# When piped to bash (e.g. gh api ... | bash), BASH_SOURCE is unset,
# so fall back to current working directory.
if [ -n "${BASH_SOURCE[0]+x}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
else
    REPO_ROOT="$(pwd)"
fi

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
cp agent-docs/AGENTS_AIDAN.md AGENTS.local.md
echo "Copied AGENTS_AIDAN.md to .cursor/rules/AGENTS_AIDAN.mdc and AGENTS.local.md"
