# Global Claude Instructions

## Pull Requests

- Use `PULL_REQUEST_TEMPLATE.md` files (typically found in `.github/` directory) as the structural reference for formatting the PR description
- Link related tickets using full URLs in the format `/task <jira-ticket-url>` (e.g., `/task https://betterconfluence.atlassian.net/browse/B2BG-349`)
- Always use conventional commit style for PR titles (e.g., `fix: resolve rate boost sync race condition`)
- Always attempt to create PRs with the `ITR:NoSkip` label (when it's available)

## Commits

Always use conventional commit style for commit messages (e.g., `fix: resolve rate boost sync race condition`, `feat: add retry logic to sync job`).

## Development Methodology

Always write code using Test-Driven Development (TDD): write failing tests first, then implement the code to make them pass.

## Code Quality

Before committing changes to code, always run the appropriate linter for the language:
- Ruby (`.rb`): rubocop
- JavaScript/TypeScript: prettier and eslint
- Other languages: use the project's configured linter if available
