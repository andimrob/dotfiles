# Codex permissions

Chezmoi derives Codex permissions from `home/dot_claude/private_settings.json.tmpl`,
including its `work`/personal split. Edit that template to change shared permissions.
No machine-local credentials or MCP endpoints are stored in this repository.

| User-level file | Purpose |
| --- | --- |
| `~/.codex/config.toml` | Select the `claude` permission profile, configure sandbox access and approvals, approve the two Jira read tools when the server already exists, and retire the listed MCP servers and plugins. |
| `~/.codex/rules/claude.rules` | Translate supported Claude Bash allow/ask entries to Codex command-prefix rules. |
| `~/.codex/rules/default.rules` | Keep approvals saved interactively by Codex; chezmoi leaves this file alone. |

The config modifier preserves unrelated values, including models, plugins,
server credentials and other named permission profiles. The retirement lists
below are the only exception. Its first update may reformat TOML and remove
comments. Later applications preserve the original text when the configuration
values already match.

## Retired servers and plugins

Two lists in `home/dot_codex/modify_private_config.toml` withdraw tooling that
every machine should stop loading:

- `$retiredServers` deletes the named entries from `mcp_servers`. Codex warns at
  startup about a server it cannot reach, so a dead endpoint costs noise on
  every launch.
- `$retiredPlugins` sets `enabled = false` on the named plugins. A plugin can
  supply its own MCP server, so disabling the plugin is what withdraws it.
  The modifier only edits a plugin that the local config already lists, so it
  never invents an entry.

The repository records the name of a retired server, never its endpoint.
Authentication is separate. Run `codex mcp login <name>` for each server you
keep; those credentials stay in `~/.codex/auth.json` on the machine.

## How the translation works

Codex has separate controls for command approvals and sandbox access:

- `approval_policy = "on-request"` allows commands within the sandbox and permits
  requests for additional access. This is not an exhaustive command allowlist.
- The `claude` profile extends `:workspace`, preserving Codex's baseline protected
  directories. It adds Claude's `.env`/`secrets` exclusions, package-store writes,
  network domains and GPG sockets. `features.network_proxy = true` is required to
  enforce domain restrictions. These controls apply to sandboxed local commands.
- `.rules` files match literal argument prefixes: `Bash(git diff *)` becomes
  `prefix_rule(pattern=["git", "diff"], decision="allow")`. Conflicting rules use
  the strictest decision: `forbidden`, then `prompt`, then `allow`.

**An `allow` rule authorizes execution outside the sandbox.** Secret exclusions
and sandbox network restrictions do not constrain those executions. This is a
material difference from treating the generated command list as a file-access
policy. The source already allows commands that run arbitrary project scripts,
as well as broad commands such as `find` and `rtk gh api`.

## Translation limits

- Codex prefixes cannot represent the six `pnpm --dir *` / `--filter *`
  test/lint/typecheck patterns. The generated file records those as comments;
  their commands retain normal sandbox/approval behavior. Run the direct command
  from its package directory, or approve an exact prefix when needed.
- Trailing wildcards attached to an RTK subcommand become whole argument matches
  (`status*` becomes `status`). Exact Claude commands such as `git status` become
  prefixes, including additional arguments.
- `Read`, `Glob` and `Grep` use sandbox filesystem access. `WebFetch` permissions
  have no matching global per-domain approval setting; the copied domain list
  comes from Claude's **sandbox** settings. It does not filter hosted web search,
  MCP, connectors, browser navigation or Computer Use.
- The two explicit Atlassian tool allows become per-tool `approval_mode =
  "approve"` overrides only when `mcp_servers.atlassian` is already configured.
  Authentication, server policy and organization restrictions still apply.
- Claude's `defaultMode = "plan"` is a workflow preference. This migration keeps
  Codex workspace editing enabled; use `/plan` for planning conversations.
- Only the user config's legacy `sandbox_mode` and `sandbox_workspace_write`
  keys are removed. A selected `~/.codex/<name>.config.toml`, trusted project config
  or CLI `--sandbox` override can select older sandbox behavior and bypass this
  default profile. Managed requirements can further constrain user settings.
- On Linux/WSL/Windows, deny globs use a scan depth of 16. Matches deeper than
  that or created after the sandbox snapshot have platform-dependent coverage.
  macOS uses Seatbelt enforcement. Approved escalations have separate controls.

## Apply and verify

Requires a Codex version supporting permission profiles, profile inheritance,
network proxy rules and per-tool MCP approval overrides. Validated with 0.154.0.
Preview locally (the config diff can contain machine-local credentials):

```sh
chezmoi diff ~/.codex/config.toml ~/.codex/rules/claude.rules
chezmoi apply ~/.codex/config.toml ~/.codex/rules/claude.rules
```

Restart Codex after applying. App/session permission selections may override
these user defaults; inspect the active profile in the permission controls.

Tests require `bats`, `chezmoi`, `codex`, and Python 3.11+:

```sh
bats home/dot_codex/permissions.bats home/dot_claude/settings.json.bats
shellcheck --shell=bash home/dot_codex/permissions.bats
codex execpolicy check --pretty --rules ~/.codex/rules/claude.rules -- git push origin main
```

`execpolicy check` reports decisions without executing the command.

References: [Codex rules](https://learn.chatgpt.com/docs/agent-configuration/rules),
[permission profiles](https://learn.chatgpt.com/docs/permissions),
[configuration layers](https://learn.chatgpt.com/docs/config-file/config-basic),
[MCP configuration](https://learn.chatgpt.com/docs/extend/mcp),
[chezmoi modify templates](https://www.chezmoi.io/user-guide/manage-different-types-of-file/#manage-part-but-not-all-of-a-file).
