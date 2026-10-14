---
name: trace-debugging
description: Finds out what went wrong from production LangSmith traces and says it plainly, starting from a pasted alert ("I got Slack errors, check what's going on"), a user report, a time, or "what went wrong this week". Reads the traces around the moment and says what users saw, who was affected, whether it's still happening and what to do. Use for alerts, errors, failures, outages, slow or missing answers, "is it down", "did anything break". For usage, topics and sentiment, use the trace-analysis skill.
---

# Trace debugging

Read `reading-traces.md` in this folder first, then the profile it points to, and follow both
throughout. For an alert, use the profile's alerts section.

The reader wants four answers, in this order: is it still happening; what did users see; who
was affected; what should we do. Engine detail only if they ask.

## 1. Work out what you're looking at

- **A pasted alert.** Find it in the profile's alerts section. Take its time and its time zone
  (a time ending in `Z` is UTC). An "open" or "triggered" alert with no matching "resolved" is
  still open.
- **"I got alerts" with nothing pasted.** If the profile names alert channels and this session
  can read them, read the newest alerts from the last 24 hours (read only; never post).
  Otherwise ask once for the alert text or the time, and meanwhile check the last two hours.
- **A complaint** ("users say answers failed this afternoon"). Ask nothing you can find:
  if the reader gives words from the question, find it with `search("<phrase>")` on
  main-source messages; otherwise use the time they give.
- **A period** ("what went wrong this week", "any failures yesterday"). Go to section 4.
- **A test system, or a system the profile says isn't connected.** Say so (no users affected,
  or not readable here) and stop.

## 2. Read the moment

Window: from 30 minutes before the alert or complaint to 15 minutes after, or to now if it may
still be going on. Convert to UTC.

1. **Failures.** `has_error: true`, the profile's answer filter, `selects: ["NAME",
   "START_TIME", "LATENCY_SECONDS", "ERROR_PREVIEW"]` (a short window holds few). Classify each
   with the profile's failure table. Leave the kinds that don't count as failures (stops by
   users) out of the failure count; report them apart.
2. **Who.** For the failures (at most 25), `["METADATA"]` with `page_size: 25`: note
   organisation, person (count only) and source.
3. **Is it answering?** Count main-source messages and answers in the window, and in the same
   window a day earlier (a week earlier if that was a non-working day). Messages arriving with
   few or no answers means answers were failing or stuck; few messages at a busy time can mean
   people couldn't get in.
4. **Slow answers** in the window, with the profile's slow filter.
5. **Still happening?** If the window ended more than 15 minutes ago, check the last 15 minutes
   to now for the same failure and count answers that went through.
6. **A server error with no failed answer.** Many server alerts come from a step inside an
   answer that carried on. Find the step: `is_root: false`, `run_type: "TOOL"`, the 30 seconds
   up to the error's time, `["NAME", "START_TIME", "TRACE_ID"]`. A step whose name matches the
   error at the same second is the one. Then check that answer's record (`trace_id`,
   `is_root: true`, `["STATUS", "LATENCY_SECONDS"]`): if it finished, say so, and that the
   traces can't show whether the answer missed what the step was fetching.
7. **What traces can't show.** Some alerts happen outside any answer and leave no trace. Say
   what the alert means for users from the profile, and whether the answers around it look
   normal. Never claim a cause the data doesn't show.

## 3. Report a moment

```
**<Still happening | Over>.** <local time range, date>: <what users saw, in one plain sentence>.
<n> people at <n> <organisations> (<labels>); <source if not the main one>.

- **Still happening:** <no: last failure hh:mm; n answers went through since | yes: n failures in the last 15 minutes>.
- **Why:** <the plain cause from the profile's tables, or "not visible in traces" and what the alert says>.
- **Rest of <product>:** <normal: n answers in the window, against n the day before | affected: ...>.
- **What to do:** <nothing | watch for a repeat | tell the engineering team, with this summary | contact the <organisation>>.
```

Leave out any line with nothing to say. If nothing failed for users, say so in the first line
("Nothing failed for users between 12:00 and 12:45; 96 answers went through."). Failures
outside the window get one line at most, and only if they are still going on.

## 4. A period ("what went wrong this week")

Default: the last 7 full days in the profile's time zone.

1. Start the `trace-counter` helper with job `totals` for the period (the base for "out of how
   many").
2. Count failures for the period without reading error text: the total, then each kind with the
   profile's failure table ("other" is the remainder), then each kind by source. Select
   `["NAME", "START_TIME", "LATENCY_SECONDS"]` so the times show bursts. Read `ERROR_PREVIEW`
   only for the "other" kind.
3. Group by kind, then by hour and day. A burst inside an hour usually means one outside event
   (for example the AI model provider); the same failure at one organisation again and again
   matters most. For a cluster, fetch `["METADATA"]` (at most 25) to see which organisations
   it hit.
4. Stops by users: count them. Most are a quick re-send or edit.
5. Slow answers: count and share of answers.

```
**<Verdict in one sentence: were users materially affected>.** <n> answers failed out of about <n> (<x in 100>), <dates>.

| What users saw | Answers | When | Where from | <Organisations> |
| ... |

- <the one or two patterns that matter: a burst, an organisation hit repeatedly, a rising trend>
- Stopped by users: <n> (<n> people stopped two or more in a row).
- Slow: <n> of <n> answers.
```

## Engine detail, on request

If the reader asks for the technical detail, give the error names, times in UTC, the answer's
`THREAD_ID` for one example, and what the error preview says (no tokens, emails or user
text). Still no full conversation dumps: they are blocked on purpose.
