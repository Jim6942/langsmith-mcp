#!/bin/sh
# Traces can carry sign-in tokens and email addresses. Replace them before Claude sees
# the result, so they can never be repeated in an answer.
# If jq fails, replace the whole result: a "block" decision would still show Claude the
# original output.
out=$(jq -c '
  def scrub:
    gsub("(?i)bearer\\s+[A-Za-z0-9._~+/=-]+"; "Bearer [token removed]")
    | gsub("eyJ[A-Za-z0-9_-]{8,}\\.[A-Za-z0-9_-]{8,}(\\.[A-Za-z0-9_-]*)?"; "[token removed]")
    | gsub("svc\\.[A-Za-z0-9._-]{16,}"; "[token removed]")
    | gsub("lsv2_[a-z]{2}_[A-Za-z0-9_]+"; "[key removed]")
    | gsub("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"; "[email removed]");
  {hookSpecificOutput: {
     hookEventName: "PostToolUse",
     updatedMCPToolOutput: (.tool_response | walk(if type == "string" then scrub else . end))
  }}' 2>/dev/null) || {
  echo '{"hookSpecificOutput":{"hookEventName":"PostToolUse","updatedMCPToolOutput":"Result withheld: the langsmith-mcp plugin could not check it for credentials. Ask a narrower question."}}'
  exit 0
}
printf '%s\n' "$out"
