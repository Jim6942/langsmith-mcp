# LangSmith MCP for Claude Code

Connects Claude Code to LangSmith's hosted MCP server and adds two skills for working with
production traces: one analyses usage, one debugs failures. Read-only.

## What's included

| Part | What it does |
|---|---|
| `langsmith` connection | LangSmith's hosted MCP server, added to Claude Code and signed in with your own LangSmith account |
| `trace-analysis` skill | A usage report from your traces: volume and trend, what users ask, and how they seem to feel |
| `trace-debugging` skill | Works out what went wrong from an alert, a time or a report: whether it's still happening, what users saw, how many were affected, what to do |
| `trace-counter` helper | Does the bulk counting in the background, so the main session stays small |
| Guards | Only read tools run, and credentials are removed from results before Claude sees them |

## Install

### With Claude

Open Claude Code (the Code tab in the Claude desktop app, or `claude` in a terminal), drag your
profile file into the message, and say:

> Install this for me: https://github.com/Jim6942/langsmith-mcp

Claude follows [INSTALL.md](INSTALL.md) and does the setup. You click Allow a few times, start a
new session and sign in to LangSmith once.

If you're Claude: fetch the guide with
`curl -fsSL https://raw.githubusercontent.com/Jim6942/langsmith-mcp/main/INSTALL.md`
and follow it step by step.

### By hand

You need Claude Code, a LangSmith account that can read your production project, and `jq`
(included with recent macOS; otherwise `brew install jq`).

1. Add LangSmith's MCP server, named exactly `langsmith` (the guards match that name). Use your
   region's address:

   ```bash
   claude mcp add --transport http --scope user langsmith https://api.smith.langchain.com/mcp
   ```

   EU: `https://eu.api.smith.langchain.com/mcp`. APAC: `https://apac.api.smith.langchain.com/mcp`.

2. Install the plugin:

   ```bash
   claude plugin marketplace add Jim6942/langsmith-mcp
   ```

   ```bash
   claude plugin install langsmith-mcp@langsmith-mcp
   ```

3. Add your profile: copy [`profile/profile-template.md`](profile/profile-template.md) to
   `~/.claude/langsmith-mcp/profile.md` and fill it in (see [Profile](#profile)).

4. Sign in: start a new Claude Code session, type `/mcp`, choose `langsmith`, then
   Authenticate, and sign in in the browser window that opens.

Add the server with the command in step 1, not as a claude.ai connector: a connector's tools
have different names, so the guards wouldn't apply to them.

## Usage

Ask in your own words. For example:

- "How are users getting on this week?"
- "Weekly report for last week."
- "I got this alert, check what's going on." (paste the alert)
- "What went wrong yesterday afternoon?"

The first time, Claude asks to use the LangSmith read tools and the helper: choose "Yes, and
don't ask again". A weekly report takes about twenty minutes, most of it counting in the
background. Follow-up questions in the same session reuse what was already read.

You can add your own skills in `~/.claude/skills/` alongside these. They share the `langsmith`
connection and the same guards. Don't edit the plugin's files in place: an update replaces them.

## Profile

The plugin is generic. A profile file at `~/.claude/langsmith-mcp/profile.md` describes your
project: the LangSmith project and region, which trace fields identify an organisation, a user
and a source, your failure types and alerts, and how to group topics. Start from
[`profile/profile-template.md`](profile/profile-template.md). The more precise the filters, the
better the reports.

The profile stays on your machine. It isn't part of this repository, and `.gitignore` excludes it.

## How it works

```
Claude Code
  ├─ connection "langsmith" ── your LangSmith sign-in ──▶ LangSmith's hosted MCP server
  ├─ profile (~/.claude/langsmith-mcp/profile.md): how your product shows up in traces
  └─ plugin langsmith-mcp
       ├─ skills: trace-analysis, trace-debugging
       ├─ helper: trace-counter
       ├─ before each LangSmith call: only list_projects, list_workspaces and query_runs run
       └─ after each call: tokens, keys and email addresses replaced before Claude reads the result
```

## Guards

- **Read-only.** A hook lets only `list_projects`, `list_workspaces` and `query_runs` run on the
  `langsmith` connection. Everything else on it is blocked: writes, sandboxes, prompts,
  datasets and whole-thread exports.
- **Credentials removed.** A second hook replaces bearer tokens, JWTs, LangSmith API keys and
  email addresses in every LangSmith result. If a result can't be checked, it is withheld.

The read-only guard applies to every `langsmith` tool in any session where the plugin is
enabled, so turn the plugin off where you need LangSmith's full toolset.

## Troubleshooting

| What you see | Why | Fix |
|---|---|---|
| "Setup isn't finished: the profile file is missing" | No profile at `~/.claude/langsmith-mcp/profile.md` | Add it (install step 3) |
| Claude can't reach LangSmith, or `/mcp` shows `langsmith` needing sign-in | Sign-in missing or expired | `/mcp`, choose `langsmith`, sign in again |
| Project not found, or no projects | Signed in to another workspace | Sign in again and pick the right workspace |
| "Blocked by the langsmith-mcp plugin" | A tool outside the three reads was tried | Expected; Claude falls back to small reads |
| "Result withheld: could not check it for credentials" | `jq` missing, or an unreadable result | Install `jq`, or ask a narrower question |
| Nothing older than a few weeks | LangSmith's trace retention | Expected |
| A headless run (`claude -p`) stops before the report | Headless sessions stop background helpers after 10 minutes | Run it interactively, or set `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0` |

## Files

```
.claude-plugin/marketplace.json
plugin/
  .claude-plugin/plugin.json
  skills/trace-analysis/    SKILL.md, reading-traces.md
  skills/trace-debugging/   SKILL.md, reading-traces.md (same file)
  agents/trace-counter.md
  hooks/hooks.json
  scripts/allow-reads.sh, redact.sh
profile/profile-template.md
INSTALL.md                  step-by-step setup, written for Claude
```

## License

MIT. See [LICENSE](LICENSE).
