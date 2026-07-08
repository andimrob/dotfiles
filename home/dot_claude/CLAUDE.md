# Global Claude Instructions

## Pull Requests

- Link related tickets using full URLs in the format `/task <jira-ticket-url>` (e.g., `/task https://betterconfluence.atlassian.net/browse/B2BG-349`)
- Always use conventional commit style for PR titles (e.g., `fix: resolve rate boost sync race condition`)
- Always create PRs with the `ITR:NoSkip` label

## Commits

Always use conventional commit style for commit messages (e.g., `fix: resolve rate boost sync race condition`, `feat: add retry logic to sync job`).

## Development Methodology

Always write code using Test-Driven Development (TDD): write failing tests first, then implement the code to make them pass.

## Code Quality

Before committing changes to code, always run the appropriate linter for the language:
- Ruby (`.rb`): rubocop
- JavaScript/TypeScript: prettier and eslint
- Other languages: use the project's configured linter if available

## Code Comments

Write self-documenting code with minimal comments. Do not add explanatory or narrative
comments (restating what a line does, why a change was made, or where code came from)
unless explicitly asked to comment something. Prefer extracting well-named variables,
methods, and tests over commenting. Keep only functional pragmas (e.g. `# rubocop:disable`,
`// eslint-disable-next-line`, `# frozen_string_literal: true`) and comments stating a
constraint the code itself cannot express.

## Temporary Files

Put temporary files (scratch scripts, screenshots, notes, intermediate outputs) in a `.scratch/` directory at the project root instead of `/tmp`, the session scratchpad, or other system temp directories. Create the directory if it doesn't exist — it is globally gitignored.

@RTK.md
