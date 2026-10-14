#!/bin/sh
# Tells every session how to sign in to LangSmith. The desktop app's /mcp doesn't finish this
# sign-in, and when the server isn't signed in Claude often answers without opening a skill,
# so the instruction can't live in the skills alone.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"langsmith-mcp plugin: if the langsmith MCP server needs sign-in (its tools are missing or it says it needs authentication), sign the person in yourself. Tell them a LangSmith sign-in page will open in their browser, then run, with a five-minute timeout: script -q /dev/null \"${CLAUDE_CODE_EXECPATH:-claude}\" mcp login langsmith . This works from a non-interactive session too. When it prints 'Authenticated with \"langsmith\"', tell them to start a new session and ask again. Never send them to /mcp: in the desktop app it doesn't finish this sign-in."}}
JSON
