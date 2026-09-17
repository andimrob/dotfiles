#!/usr/bin/env bats

setup() {
	printf '[data]\nwork = true\npersonal = false\n' >"$BATS_TEST_TMPDIR/chezmoi.toml"
	CODEX_RULES="$BATS_TEST_TMPDIR/claude.rules"
}

render() {
	chezmoi -c "$BATS_TEST_TMPDIR/chezmoi.toml" --config-format=toml \
		--source "$BATS_TEST_DIRNAME/.." --destination "$BATS_TEST_TMPDIR/home" \
		execute-template --with-stdin --file "$BATS_TEST_DIRNAME/$1"
}

render_rules() {
	[ -f "$BATS_TEST_DIRNAME/rules/claude.rules.tmpl" ]
	render rules/claude.rules.tmpl </dev/null >"$CODEX_RULES"
}

decision() {
	codex execpolicy check --rules "$CODEX_RULES" -- "$@" |
		python3 -c 'import json, sys; print(json.load(sys.stdin).get("decision", "unmatched"))'
}

@test "shared development commands are allowed by Codex" {
	render_rules
	for command in 'npm run lint' 'yarn install' 'pnpm run build' 'bundle install' 'rubocop app.rb' 'prettier --check .' 'eslint .' 'git status' 'git diff HEAD' 'git log -5' 'git branch --show-current' 'pytest tests' 'rspec spec' 'jest' 'vitest run'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = allow ]
	done
}

@test "work rules allow commits, direct pnpm tasks, searches, and RTK commands" {
	render_rules
	for command in 'git commit -m example' 'pnpm test --run' 'pnpm lint' 'pnpm typecheck' 'rtk grep pattern' 'rtk git show HEAD' 'rtk gh pr view 123' 'rtk gh api repos/owner/repo' 'rg pattern' 'find . -name README.md'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = allow ]
	done
}

@test "push, infrastructure, and recursive removal require approval" {
	render_rules
	for command in 'git push origin main' 'git push --force origin main' 'git force-push origin main' 'docker ps' 'kubectl get pods' 'rm -rf build'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = prompt ]
	done
}

@test "wildcard arguments and unrelated commands never become blanket allows" {
	render_rules
	for command in 'pnpm --dir app test' 'pnpm --filter app test' 'pnpm --dir app exec arbitrary' 'pnpm publish' 'git reset --hard' 'rtk git reset --hard' 'bash -c arbitrary'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = unmatched ]
	done
}

@test "personal rules retain shared permissions without work-only allows" {
	printf '[data]\nwork = false\npersonal = true\n' >"$BATS_TEST_TMPDIR/chezmoi.toml"
	render_rules
	[ "$(decision npm run lint)" = allow ]
	[ "$(decision git push origin main)" = prompt ]
	[ "$(decision git commit -m example)" = unmatched ]
	[ "$(decision rtk gh api repos/owner/repo)" = unmatched ]
}

@test "config migration preserves local settings and removes legacy sandbox overrides" {
	[ -f "$BATS_TEST_DIRNAME/modify_private_config.toml" ]
	render modify_private_config.toml <<'TOML' >"$BATS_TEST_TMPDIR/result.toml"
model = "local-model"
sandbox_mode = "workspace-write"
[sandbox_workspace_write]
network_access = false
[features]
multi_agent = true
[mcp_servers.atlassian]
url = "https://example.invalid/mcp"
[mcp_servers.atlassian.http_headers]
Authorization = "local-only-value"
[mcp_servers.atlassian.tools.otherTool]
approval_mode = "prompt"
[permissions.other]
extends = ":read-only"
TOML
	python3 - "$BATS_TEST_TMPDIR/result.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], 'rb') as f:
    c = tomllib.load(f)
assert c['model'] == 'local-model'
assert c['features']['multi_agent'] is True
assert c['features']['network_proxy'] is True
assert 'sandbox_mode' not in c and 'sandbox_workspace_write' not in c
assert c['approval_policy'] == 'on-request'
assert c['default_permissions'] == 'claude'
assert c['permissions']['other']['extends'] == ':read-only'
a = c['mcp_servers']['atlassian']
assert a['url'] == 'https://example.invalid/mcp'
assert a['http_headers']['Authorization'] == 'local-only-value'
assert a['tools']['otherTool']['approval_mode'] == 'prompt'
assert a['tools']['getJiraIssue']['approval_mode'] == 'approve'
assert a['tools']['getAccessibleAtlassianResources']['approval_mode'] == 'approve'
PY
}

@test "fresh configs carry secret exclusions and proxy-enforced work domains" {
	[ -f "$BATS_TEST_DIRNAME/modify_private_config.toml" ]
	render modify_private_config.toml </dev/null >"$BATS_TEST_TMPDIR/result.toml"
	python3 - "$BATS_TEST_TMPDIR/result.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], 'rb') as f:
    c = tomllib.load(f)
p = c['permissions']['claude']
assert p['extends'] == ':workspace'
fs = p['filesystem'][':workspace_roots']
for path in ['.env', '.env.*', 'secrets/**', '**/.env', '**/.env.*', '**/secrets/**']:
    assert fs[path] == 'deny', path
assert c['features']['network_proxy'] is True
assert p['network']['enabled'] is True
for host in ['github.com', 'registry.npmjs.org', 'betterconfluence.atlassian.net']:
    assert p['network']['domains'][host] == 'allow'
assert '*' not in p['network']['domains']
assert 'mcp_servers' not in c
assert 'plugins' not in c
PY
}

@test "personal config excludes work domains and cache writes" {
	[ -f "$BATS_TEST_DIRNAME/modify_private_config.toml" ]
	printf '[data]\nwork = false\npersonal = true\n' >"$BATS_TEST_TMPDIR/chezmoi.toml"
	render modify_private_config.toml </dev/null >"$BATS_TEST_TMPDIR/result.toml"
	python3 - "$BATS_TEST_TMPDIR/result.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], 'rb') as f:
    c = tomllib.load(f)
p = c['permissions']['claude']
assert p['network']['domains']['github.com'] == 'allow'
for host in ['betterconfluence.atlassian.net', 'circleci.com', 'app.circleci.com']:
    assert host not in p['network']['domains']
assert not any('pnpm/store' in key for key in p['filesystem'])
PY
}

@test "the migration removes retired MCP servers and keeps the rest" {
	[ -f "$BATS_TEST_DIRNAME/modify_private_config.toml" ]
	render modify_private_config.toml <<'TOML' >"$BATS_TEST_TMPDIR/result.toml"
[mcp_servers.paper]
url = "http://127.0.0.1:29979/mcp"
[mcp_servers.keepme]
url = "https://example.invalid/mcp"
TOML
	python3 - "$BATS_TEST_TMPDIR/result.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], 'rb') as f:
    c = tomllib.load(f)
servers = c['mcp_servers']
assert 'paper' not in servers
assert servers['keepme']['url'] == 'https://example.invalid/mcp'
PY
}

@test "the migration disables retired plugins and leaves others enabled" {
	[ -f "$BATS_TEST_DIRNAME/modify_private_config.toml" ]
	render modify_private_config.toml <<'TOML' >"$BATS_TEST_TMPDIR/result.toml"
[plugins."linear@claude-plugins-official"]
enabled = true
[plugins."context7@claude-plugins-official"]
enabled = true
TOML
	python3 - "$BATS_TEST_TMPDIR/result.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], 'rb') as f:
    c = tomllib.load(f)
plugins = c['plugins']
assert plugins['linear@claude-plugins-official']['enabled'] is False
assert plugins['context7@claude-plugins-official']['enabled'] is True
PY
}

@test "reapplying the config migration produces identical output" {
	[ -f "$BATS_TEST_DIRNAME/modify_private_config.toml" ]
	render modify_private_config.toml </dev/null >"$BATS_TEST_TMPDIR/first.toml"
	render modify_private_config.toml <"$BATS_TEST_TMPDIR/first.toml" >"$BATS_TEST_TMPDIR/second.toml"
	cmp "$BATS_TEST_TMPDIR/first.toml" "$BATS_TEST_TMPDIR/second.toml"
}
