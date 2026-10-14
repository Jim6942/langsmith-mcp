# Reading production traces

Shared by both skills in this plugin. The two copies are identical; change both together.

## First: the profile

Read the profile before anything else: `~/.claude/langsmith-mcp/profile.md` (your home
folder, then `.claude/langsmith-mcp/profile.md`). It names the product, the readers, the
LangSmith project, how messages, answers, sources, organisations and people appear in the
traces, the failure kinds, and the alerts. Every "the profile" below means that file.

If the file is missing or still has `<fill in>` placeholders in its required sections, stop
and say: "Setup isn't finished: the profile file is missing. See the plugin's README." Never
guess a project name or a filter.

## Then: the connection

- If the LangSmith tools (`query_runs`) aren't available in this session, LangSmith isn't
  signed in. Say: "LangSmith isn't signed in. A sign-in page will open in your browser: sign
  in, then start a new session and ask again." Then run, with a five-minute timeout,
  `script -q /dev/null "${CLAUDE_CODE_EXECPATH:-claude}" mcp login langsmith` and stop. If
  `langsmith` isn't set up at all, say: "Ask me to install this again from its link." Then stop.
- Make your first call `list_projects` with the profile's project name. If it isn't found,
  say: "You're signed in to a different LangSmith workspace. A sign-in page will open: pick the
  <profile's workspace> workspace, then start a new session and ask again." Then run
  `"${CLAUDE_CODE_EXECPATH:-claude}" mcp logout langsmith` and the sign-in command above, and
  stop.

## The reader

Unless the profile says otherwise: someone who runs the business, knows the subject the
product serves, and doesn't read code. They want facts: what users did, whether it worked, how
they seem to feel, what to do. Write for them:

- Plain product words: message, answer, the profile's word for an organisation, person,
  conversation, the profile's source names. Never: trace, run, root, span, thread, node,
  graph, token, latency, metadata, filter.
- Every number says what it counts and over what period ("2,140 messages, 7-13 Oct").
- Short. No preamble, no reassurance, no restating the question, no closing summary.
- Times in the profile's time zone. Traces are in UTC: convert both ways, and mind the
  daylight-saving change dates.
- Engine detail (error names, step counts, model or vendor names) only when the reader asks
  for it.
- Never mention this plugin, its skills, the profile, releases, versions or code. Say what
  happened to users, not how you found it.

## Querying

Tools: only `query_runs`, plus `list_projects` and `list_workspaces`. Everything else on the
LangSmith server is blocked by this plugin.

- Every call: the profile's `project_name`, `is_root: true` (unless you are looking for a step
  inside an answer), explicit `min_start_time` and `max_start_time`, a short `selects` list.
  Never select `INPUTS`, `OUTPUTS`, `EXTRA` or `EVENTS`; the `*_PREVIEW` fields are enough.
- Page with `next_cursor`, same filters and times, `page_size` up to 100.
- `METADATA` is large (often about 2 KB a record): select it only with `page_size` 25 or less,
  and never page a whole day with it.
- **Counting.** The count is the number of rows returned. Filter so every row is the thing
  being counted and select `[]` (ids only) or `["START_TIME"]`. A full page is 100; count only
  the last page, carefully.
- **Metadata filters.** Always pair `metadata_value` with `metadata_key`:
  `and(eq(metadata_key, "<key>"), eq(metadata_value, "<value>"))`. A `metadata_value` filter
  on its own silently matches everything.
- **Listing every organisation or person exactly.** Query with `page_size: 1` and
  `["METADATA"]`; note the ID. Query again with
  `not(and(eq(metadata_key, "<key>"), eq(metadata_value, "<id>")))` added for each ID found,
  until the result is empty. The empty result proves the list is complete. Keep the full IDs
  for follow-up queries only.
- **Failure kinds, counted without reading error text.** `has_error: true` plus
  `search("<phrase>")` with each phrase from the profile's failure table; "other" is the total
  minus the named kinds (`not(search(...))` is refused by the server). `search(...)` combines
  with source and latency filters, for example `and(search("<phrase>"), gt(latency, 190))`.
- **Finding a message by its words:** the profile's message filter plus
  `search("<distinctive phrase>")`.
- **One conversation:** `eq(thread_id, "<id>")`. One exchange: the profile's pairing key.
- An empty result means "none" only when the query ran and could have matched. If unsure, run
  the same filter on a wider window and check it returns something.
- One read at a time. If LangSmith answers "429 Too Many Requests", wait a few seconds and
  retry once. If a read is refused, don't retry it in a loop: narrow it and say what was
  skipped.
- Traces are kept for the profile's retention period. Nothing older can be read.

## Privacy, always

- Never show a person's name, email, ID, or any token or key. The plugin strips credentials and
  emails before you see them; "[token removed]" needs no comment.
- An organisation is shown as the profile's label plus the first four characters of its ID
  (for example "Org 7f2a"). Never guess a name.
- People are counted, never identified.
- Summarise what users asked. Quote a user only when the reader asks, at most one short quote
  per conversation, and leave out names, companies and figures in it.
- Message previews can contain pasted emails, company names and figures. Never repeat them.
- Nothing from traces goes into a file, email or message unless the reader asks, and then only
  the summary.
- Never save anything from traces, or any figure from a report, to memory. Each request reads
  LangSmith afresh.
