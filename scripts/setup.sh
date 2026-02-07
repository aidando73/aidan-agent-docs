#!/bin/bash
set -euo pipefail

# Clone agent-docs + dotfiles repos and install AGENTS_AIDAN.md as a Cursor rule
# Run from the root of the fireworks repo

cd "$(pwd)"

if [ -d "agent-docs" ]; then
    echo "agent-docs/ already exists, pulling latest..."
    git -C agent-docs pull
else
    echo "Cloning agent-docs..."
    git clone https://github.com/aidando73/agent-docs.git agent-docs
fi

if [ -d "dotfiles" ]; then
    echo "dotfiles/ already exists, pulling latest..."
    git -C dotfiles pull
else
    echo "Cloning dotfiles..."
    gh repo clone aidando73/dotfiles dotfiles
fi

mkdir -p ~/.cursor/commands/
cp agent-docs/user_commands/* ~/.cursor/commands/

mkdir -p .cursor/rules
cp agent-docs/AGENTS_AIDAN.md .cursor/rules/AGENTS_AIDAN.mdc
cp agent-docs/AGENTS_AIDAN.md AGENTS.local.md
echo "Copied AGENTS_AIDAN.md to .cursor/rules/AGENTS_AIDAN.mdc and AGENTS.local.md"
