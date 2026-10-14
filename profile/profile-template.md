# Profile

Copy this file to `~/.claude/langsmith-mcp/profile.md` and fill it in. It tells the skills how
your product shows up in LangSmith. Keep it out of any repository: it describes your
production data.

Replace every `<fill in>`. Sections marked optional can be deleted.

## Product and readers

- Product name: <fill in>
- Who reads the reports: <fill in, e.g. "the founders; they know the subject well and don't read code">
- Word for an organisation: <fill in, e.g. "firm", "customer", "workspace">; shown as
  <fill in, e.g. "Firm"> plus the first four characters of its ID
- Time zone for reports: <fill in, e.g. "UK time: UTC+1 until 25 Oct 2026, then UTC">
- Working days, for comparisons: <fill in, e.g. "Monday to Friday">

## Where the data is

- LangSmith project: `<fill in>`
- LangSmith MCP server: `<fill in: https://api.smith.langchain.com/mcp (US), https://eu.api.smith.langchain.com/mcp (EU) or https://apac.api.smith.langchain.com/mcp (APAC)>`
- LangSmith workspace: <fill in: the workspace name to pick when signing in>
- Traces are kept for: <fill in, e.g. "14 days">
- Ignore: <fill in: test or staging projects, if any>
- Not connected here: <optional: other regions or servers, so the skills can say so>

## Messages and answers

Each thing a person types makes a "message" record; the product's reply is an "answer" record.
Both are root records (`is_root: true`).

- One message on the main source: `<fill in filter>`; its `INPUTS_PREVIEW` is what the person typed.
- Answers: records named <fill in>. Never add messages and answers together.
- Pairing a message with its answer: metadata key `<fill in>` (optional)
- A conversation is: <fill in, e.g. "the answer's THREAD_ID">

## Sources

The first row is the main source: topics and mood are read from it.

| Source, in the readers' words | Filter (one message or answer each) | Organisation key | Person key | Notes |
|---|---|---|---|---|
| <fill in> | `<fill in>` | `<fill in>` | `<fill in or "none">` | |

## Failure kinds

Matched with `has_error: true` plus `search("<phrase>")`. Anything not matched is "other".

| Search phrase | Extra condition | Say | Counts as a failure? |
|---|---|---|---|
| `<fill in>` | <optional, e.g. "latency 190-215 s"> | <fill in, plain words> | <yes, or no and why> |

## Slow answers (optional)

- Filter: `<fill in>` with `has_error: false`
- Say: <fill in, e.g. "answered, but slowly (over 2 minutes)">

## Ratings (optional)

<Where ratings live if not in traces, so the skills don't look for them.>

## Topics (optional)

<How to group what users ask: the areas, and the detail to name in each. The more specific,
the more useful the "what users asked" section.>

## Alerts (optional)

<Channels and alert titles, and what each means for users, so the trace-debugging skill can read a
pasted alert. A table per kind works well:>

| Alert title or text contains | What users may have felt | Check in traces |
|---|---|---|
| <fill in> | <fill in> | <fill in> |
