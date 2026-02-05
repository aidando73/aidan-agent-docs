#!/bin/bash
#
# Fetch PR diffs from multiple GitHub repositories
#
# Usage:
#   ./scripts/fetch_pr_diffs.sh
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - jq installed
#
# Configuration:
#   - Edit the REPOS array below to specify which repositories to fetch from
#   - Edit GITHUB_USER to change the PR author filter

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# GitHub username to filter PRs by
GITHUB_USER="aidando73"

# List of repos to fetch PRs from (owner/repo format)
REPOS=(
    "fw-ai/fireworks"
    "aidando73/flashinfer"
    "aidando73/flashinfer1"
    "aidando73/cutlass"
    "aidando73/cutlass-1"
    # Add more repos here
)

OUTPUT_DIR="$REPO_ROOT/pr_diffs"
mkdir -p "$OUTPUT_DIR"

for repo in "${REPOS[@]}"; do
    echo "=== Processing repo: $repo ==="
    
    # Create a safe directory name from repo (replace / with -)
    repo_dir=$(echo "$repo" | tr '/' '-')
    mkdir -p "$OUTPUT_DIR/$repo_dir"
    
    for n in $(gh pr list -R "$repo" --author "$GITHUB_USER" --state open --limit 500 --json number | jq '.[].number'); do
        echo "Fetching PR #$n from $repo..."

        # Get PR title
        pr_title=$(gh pr view -R "$repo" $n --json title -q '.title' 2>/dev/null)
        pr_url="https://github.com/$repo/pull/$n"

        # Try fetching the diff; skip on failure
        diff_file="$OUTPUT_DIR/$repo_dir/pr_$n.diff"
        if gh pr diff -R "$repo" $n > "$diff_file.tmp" 2>/dev/null; then
            # Prepend header with repo, PR link, and title
            {
                echo "# Repository: $repo"
                echo "# PR: $pr_url"
                echo "# Title: $pr_title"
                echo "#"
                echo ""
                cat "$diff_file.tmp"
            } > "$diff_file"
            rm -f "$diff_file.tmp"
            echo "Saved $diff_file"
        else
            echo "Skipping PR #$n (diff too large or error)"
            rm -f "$diff_file.tmp"
        fi
    done
done

# Create AGENTS.md for the pr_diffs directory
cat > "$OUTPUT_DIR/AGENTS.md" << 'EOF'
# PR Diffs

This directory contains diffs from open pull requests across multiple repositories.

## Guidelines for AI Agents

When responding about code in these diffs:

- **Always link to the PR** - Each diff file contains a `# PR:` header with the GitHub URL. Include this link in your responses so the user can easily navigate to the PR.
- **Reference the repository** - Include the repository name from the `# Repository:` header for context.
- **Quote the PR title** - Use the `# Title:` header to provide context about what the PR is doing.

Example response format:
> In [PR #123: Fix attention indexing](https://github.com/fw-ai/fireworks/pull/123) from `fw-ai/fireworks`, the change modifies...
EOF

echo ""
echo "Done! PR diffs saved to $OUTPUT_DIR"
echo "Created $OUTPUT_DIR/AGENTS.md"
