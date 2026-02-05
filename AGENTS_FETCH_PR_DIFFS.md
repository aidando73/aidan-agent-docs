# Fetch PR Diffs

## When to Use

When the user asks to "search my PRs" or similar queries about their open pull requests, run this script to fetch the latest PR diffs, then search through the `pr_diffs/` directory.

## `scripts/fetch_pr_diffs.sh`

Fetches PR diffs from multiple GitHub repositories and saves them locally with metadata headers.

### Usage

```bash
./scripts/fetch_pr_diffs.sh
```

### Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- `jq` installed

### Configuration

Edit the script to customize:
- `GITHUB_USER` - GitHub username to filter PRs by
- `REPOS` array - List of repositories to fetch from (in `owner/repo` format)

### Output

- Creates `pr_diffs/` directory with subdirectories for each repository
- Each diff file includes headers with repository, PR URL, and title
- Creates `pr_diffs/AGENTS.md` with guidelines for AI agents working with the diffs
