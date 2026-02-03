# Global Claude Instructions

## Pull Requests

When creating PR descriptions, always use `PULL_REQUEST_TEMPLATE.md` files (typically found in `.github/` directory) as the structural reference for formatting the PR description.

## Code Quality

Before committing changes to code, always run the appropriate linter for the language:
- Ruby (`.rb`): rubocop
- JavaScript/TypeScript: prettier and eslint
- Other languages: use the project's configured linter if available
