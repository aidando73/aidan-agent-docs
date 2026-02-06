#!/bin/bash
#
# Fetch PR diffs from multiple GitHub repositories
#
# Usage:
#   ./scripts/fetch_pr_diffs.sh [--force]
#
# Options:
#   --force    Re-download all diffs, even if they already exist
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - jq installed
#
# Configuration:
#   - Edit the REPOS array below to specify which repositories to fetch from
#   - Edit GITHUB_USER to change the PR author filter

set -e

# Parse arguments
FORCE=false
if [[ "$1" == "--force" ]]; then
    FORCE=true
fi

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
        diff_file="$OUTPUT_DIR/$repo_dir/pr_$n.diff"
        
        # Check if we need to download
        if [[ -f "$diff_file" && "$FORCE" == "false" ]]; then
            # Get PR's last updated timestamp
            pr_updated_at=$(gh pr view -R "$repo" $n --json updatedAt -q '.updatedAt' 2>/dev/null)
            pr_updated_epoch=$(date -d "$pr_updated_at" +%s 2>/dev/null)
            file_epoch=$(stat -c %Y "$diff_file" 2>/dev/null)
            
            if [[ -n "$pr_updated_epoch" && -n "$file_epoch" && "$file_epoch" -ge "$pr_updated_epoch" ]]; then
                echo "Skipping PR #$n (up to date)"
                continue
            else
                echo "PR #$n has been updated, re-downloading..."
            fi
        fi
        
        echo "Fetching PR #$n from $repo..."

        # Get PR title and branch
        pr_info=$(gh pr view -R "$repo" $n --json title,headRefName 2>/dev/null)
        pr_title=$(echo "$pr_info" | jq -r '.title')
        pr_branch=$(echo "$pr_info" | jq -r '.headRefName')
        pr_url="https://github.com/$repo/pull/$n"

        # Try fetching the diff; skip on failure
        if gh pr diff -R "$repo" $n > "$diff_file.tmp" 2>/dev/null; then
            # Prepend header with repo, PR link, branch, and title
            {
                echo "# Repository: $repo"
                echo "# PR: $pr_url"
                echo "# Branch: $pr_branch"
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
- **Reference the branch** - Include the branch name from the `# Branch:` header.
- **Quote the PR title** - Use the `# Title:` header to provide context about what the PR is doing.

Example response format:
> In [PR #123: Fix attention indexing](https://github.com/fw-ai/fireworks/pull/123) from `fw-ai/fireworks`, the change modifies...
EOF

echo ""
echo "Done! PR diffs saved to $OUTPUT_DIR"
echo "Created $OUTPUT_DIR/AGENTS.md"
