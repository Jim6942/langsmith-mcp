# Install guide for Claude

This file is written for Claude. When someone asks you to install this plugin, follow these
steps in order and do all the work yourself. The person may not be technical.

## How to work

- Before each step, say in one short plain sentence what you're doing ("Checking your Claude
  version."). No technical detail unless they ask.
- Run every command yourself. Never ask them to type in Terminal.
- Ask them only for what only they can do: clicking Allow on a command, giving you the profile
  file, starting a new session, and signing in to LangSmith.
- If a step fails, try the fix given here once. If that fails too, say plainly what's wrong and
  what they should send to whoever gave them this link. Don't improvise around a failed step.
- Never print or repeat a token, key or password.

Start by telling them: "I'll set this up for you. It takes about five minutes. I'll need you to
click Allow a few times, send me one file, and sign in to LangSmith once."

## Step 1: Claude Code command

Run `echo "$CLAUDE_CODE_EXECPATH"`. In the Claude desktop app this prints the path of the app's
own Claude Code, which is always current: use that path, in double quotes, in place of `claude`
for every later step, check it with `"<path>" --version`, and go to step 2. A `claude` found on
the Mac's PATH can be an older, separate copy.

If it prints nothing, run `claude --version`.

- 2.1.280 or newer: go on.
- Older: run `claude update`, then check again.
- Not found, or still older: run the official installer,
  `curl -fsSL https://claude.ai/install.sh | bash`, then use `~/.local/bin/claude` in place of
  `claude` for every later step, and check `~/.local/bin/claude --version`.

## Step 2: jq

Run `command -v jq || ls /usr/bin/jq`. The plugin's guards need it.

- Found: go on.
- Missing: if `command -v brew` finds Homebrew, run `brew install jq`. Otherwise stop and say:
  "Your Mac needs a small tool called jq. Please ask whoever sent you this link to help install
  it." Without jq the guards withhold every result, so nothing would work.

## Step 3: the profile

The profile is a private file their administrator gives them (`profile.md`). It says which
LangSmith project to read and how. It is never in this repository.

1. If they attached a profile file to their message, or pasted its text, save that as
   `~/.claude/langsmith-mcp/profile.md` (`mkdir -p ~/.claude/langsmith-mcp` first, then
   `chmod 600` it) and go to 4. Otherwise look for it:
   `ls -l ~/.claude/langsmith-mcp/profile.md ~/Downloads/profile*.md ~/Desktop/profile*.md 2>/dev/null`
2. If it's only in Downloads or Desktop, move it into place (use the newest if there are
   several):
   `mkdir -p ~/.claude/langsmith-mcp && mv "<found file>" ~/.claude/langsmith-mcp/profile.md && chmod 600 ~/.claude/langsmith-mcp/profile.md`
3. If it's nowhere, say: "I need the profile file your administrator sent you. It's called
   profile.md. Please drag it into this chat." Wait, then repeat 1.
4. Read it. Note the **LangSmith MCP server** and **LangSmith workspace** lines under "Where the
   data is". If it still contains `<fill in>` in those lines, stop and say the profile isn't
   finished and they should ask their administrator for the completed one.

## Step 4: the LangSmith connection

Run `claude mcp list`.

- A server named exactly `langsmith` with the profile's server address: go on.
- One named `langsmith` with another address: remove it with
  `claude mcp remove --scope user langsmith`, then add it as below.
- Otherwise add it:
  `claude mcp add --transport http --scope user langsmith <the profile's LangSmith MCP server>`

It must be named `langsmith` and added this way. A LangSmith connector added through Claude's
settings page doesn't count: the plugin's guards don't apply to it.

## Step 5: the plugin

Run:

```bash
claude plugin marketplace add Jim6942/langsmith-mcp
```

```bash
claude plugin install langsmith-mcp@langsmith-mcp
```

If it says it's already installed, run
`claude plugin marketplace update langsmith-mcp` and
`claude plugin update langsmith-mcp@langsmith-mcp` instead.

Check with `claude plugin list`: `langsmith-mcp` should be listed and enabled.

## Step 6: hand over the last two clicks

Say this, filling in the workspace from the profile:

"Nearly done. Two things only you can do:

1. Start a new session: the new tools load when a session starts.
2. In the new session, type `/mcp`, choose **langsmith**, then **Authenticate**. Sign in to
   LangSmith in the browser window that opens, and pick the **<workspace>** workspace if it
   asks.

Then ask: **How are users getting on this week?** The first time, Claude asks permission to read
LangSmith: choose **Yes, and don't ask again**."

## If something goes wrong later

The skills check the connection on every request and explain what to do in plain words. To
reinstall, ask Claude to install this again from the same link: every step above is safe to
repeat.
