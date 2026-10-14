---
name: trace-analysis
description: A usage report from one read of production LangSmith traces, covering how much the product is used (messages, organisations, people, trend), what users ask (in the depth the profile sets), and how they seem to feel. Opens with a short overview, then a section each. Use for "how are users getting on", "weekly report", "usage", "which organisations are active", "what are people asking", "are users happy", or any question about activity, topics or sentiment in the traces. For failures and alerts, use the trace-debugging skill.
---

# Trace analysis

Read `reading-traces.md` in this folder first, then the profile it points to, and follow both
throughout. "Organisation" below means the profile's word for one (for example "firm").

## Period

- Default: the last 7 full days in the profile's time zone, ending at midnight last night.
- The reader's period if given. Nothing older than the profile's retention can be read.
- Comparison: the full days before the period that are still kept, up to 7. The first complete
  day is the one that starts after (now minus the retention period); check this before
  querying. Compare per working day, because the two periods can differ in length.
- Convert every day boundary to UTC before querying.

Tell the reader in one line that the report takes about twenty minutes, then start.

## The data pass (once; every section uses it)

Start steps 1 and 2 together, then run 3 to 5 while they work.

1. **Counts for the period.** Start the `trace-counter` helper with job `full`, the period in
   UTC and its day boundaries. It returns messages per day by source, every active
   organisation with its message and people counts, and its own checks.
2. **Counts for the comparison.** Start a second `trace-counter` with job `totals` for the
   comparison period.
3. **Failures and slow answers.** Count, don't read: `has_error: true`, `selects: ["NAME",
   "START_TIME", "LATENCY_SECONDS"]`, the profile's answer filter. Count all failed answers,
   then each kind with the profile's failure table ("other" is the remainder), then each kind
   by source. Keep the times of stops by users for the mood section. Count slow answers with
   the profile's slow filter.
4. **Messages to read.** For each day in the period, main-source messages in two one-hour
   windows, 10:00-11:00 and 14:00-15:00 local time, `selects: ["ID", "START_TIME",
   "INPUTS_PREVIEW"]`, first page only, `page_size: 50`. This is the sample for topics and
   mood; note how many messages it holds and its share of the period's total.
5. **Who the signals came from.** For the messages you tag as corrections, frustration or
   re-sends (at most 25), fetch `["METADATA"]` by `ids` with `page_size: 25` and note each
   one's organisation.

Read nothing else. If the reader later asks for more detail, query only what that question
needs.

## Reading the messages

**Topics.** Group the sample with the profile's topics section, at the depth it asks for. Shares
are of the sample; say so once. With no topics section, group by subject in plain words.

**Mood.** Tag each message that responds to an answer (a follow-up). Judge meaning, not keywords
("no worries, thanks" is positive).

- Positive: thanks, "great", "perfect", "good start", building on the answer.
- Correction or challenge: "no", "that's wrong", "are you sure", "you missed", pointing to
  another rule, year or fact, or doubting that a cited source exists. The last matters most:
  say so separately.
- Frustration: annoyance, "still isn't what I need", "give me a yes or no", "???", capitals.
- Quick re-send: the same or nearly the same text again within 30 seconds, usually stopping the
  first answer. A double click or a quick edit, not unhappiness: count it apart.
- Repeated request: the same instruction two or more times within a minute without a stop
  ("download this as a Word document" three times). The product probably didn't do what was
  asked: name the request.
- Neutral: a plain next step or a new question. Most follow-ups are neutral.

Identical text from several organisations or on many days is a prefilled prompt or a saved
template, not a re-send: check before tagging.

Link mood to failures: a re-ask or frustrated message minutes after a failed or stopped answer
(step 3) is the strongest unhappy signal. Count those.

If the profile says where ratings live, mood here still comes only from what people wrote.

## The report

Plain, short, facts only. Tables for numbers. No paragraph longer than two sentences.
Organisations by their short label. Never a person's ID, a name, or a quote (unless the reader
asks).

```
**<Product> users, <period as "7-13 Oct">** (<main source> unless stated)

- **Use:** <n> messages from <n> people at <n> <organisations>; <n> a working day, <up/down x%> on <comparison>.
- **Asked most:** <area> (<x%>: <two or three specific points>); <area> (...); <area> (...).
- **Mood:** <one-line verdict>. <n> corrections or challenges, <n> frustrated, <n> positive, <n> repeated requests.
- **Failures:** <n> answers failed (<x in 100>); <the biggest cause in a few words>. Ask "what went wrong" for detail.

## Usage
| Day | <one column per source> |
| <Organisation> | Messages | People | Per working day, before -> now (working-day messages / working days) |
<one or two bullets: organisations that started, went quiet, or changed most; weekends are naturally quiet>

## What users asked
<sample size line>
| Area | Share | What they're probing |
<bullets from the profile's "what to bring out", only the ones with something to say>

## How users feel
| Signal | Count | About |
<one or two bullets: the link to failures; organisations where corrections or frustration cluster>

<one line: what was read - project, dates, counted in full or sampled, and the sample size>
```

Caveats: at most one line, and only for a number that could mislead a decision. Never comment
on files, rules, the helpers or how you worked. Leave out any row or bullet with nothing in it. List at most the 12 busiest organisations and
put the rest in one "others" row. If a helper fails or a count can't be checked, say which
number is missing rather than estimating it.
