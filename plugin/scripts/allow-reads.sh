#!/bin/sh
# Only the read tools these skills use may run. Anything else on the LangSmith server
# (sandboxes, prompt edits, datasets, insights jobs) is blocked, and so is the full
# conversation dump, which returns millions of characters.
# Fails closed: if jq is missing or the input is odd, nothing runs.
name=$(jq -r '.tool_name' 2>/dev/null)
case "$name" in
  mcp__langsmith__list_projects|mcp__langsmith__list_workspaces|mcp__langsmith__query_runs)
    exit 0 ;;
esac
echo "Blocked by the langsmith-mcp plugin: only list_projects, list_workspaces and query_runs are allowed. Use query_runs with small selects instead." >&2
exit 2
