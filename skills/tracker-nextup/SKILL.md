---
name: tracker-nextup
description: Rebuilds the "— next up (from database) —" checkbox block under each course toggle on the Notion Homework Tracker page from the Assignments & Exams database. User-triggered only ("/tracker-nextup", "refresh next up", "refresh the tracker checklist", or a `claude -p` run of bin/tracker-nextup.sh). Page body only — never touches the database, never a Status. NOT part of triage or coursework-sync.
---

# Tracker Next-Up Refresh

## What this is

Rohan works off the **checkbox list** under the four course toggles on the Notion
**Homework Tracker** page (the `# 📌 Back-to-school catch-up` section). The
Assignments & Exams database underneath is just his helper for "what's next / what's
done." This skill copies the soonest upcoming database items into that checklist so
the page stays his single working surface.

- **User-triggered only.** Not session start, not a greeting, not `daily-triage` /
  `act-on-triage`, not `coursework-sync`. Triggers: `/tracker-nextup`, "refresh next
  up", "refresh the tracker checklist", `bin/tracker-nextup.sh`.
- Run it after `coursework-sync` (which refreshes the *database*, not these lines),
  or any time Rohan wants the checklist re-synced.
- Safe to re-run: it fully rebuilds each course's block every time.
- Cheap enough for Haiku — steps are mechanical, no judgement.

## Autonomy (fixed — do not widen)

| Allowed, no asking | Never |
|---|---|
| Rewrite the `— next up (from database) —` block inside each of the 4 course toggles | Touch the Assignments & Exams database or the Courses database |
| — | Change any row's `Status` (including via the page checkboxes — see note) |
| — | Edit any database **view** (that's `coursework-sync`'s job) |
| — | Edit any other part of the page (callout, the non-dated items above the marker, the legacy grades toggle, the inline databases) |
| — | Send email / Discord / anything external |

**Checkbox note:** ticking a box on the page does **not** update the database — it's
just visual. Rohan marks things Done in the database (its helper role). This skill
drops an item from the checklist once it's Done in the DB *or* its due date has
passed, so a box he ticked will clear itself on the next run.

## IDs

| Thing | ID |
|---|---|
| Homework Tracker page | `2bdc2548-3c83-8073-a49d-d49b7cd3aa1f` |
| Assignments & Exams data source | `collection://db16daa8-1c51-43cb-951c-c59ed5d551fc` |

Course row URL (in the DB `Course` relation) → toggle heading on the page:

| DB `Course` contains | Toggle heading text (match exactly) | color |
|---|---|---|
| `3c9c25483c8381cc80f4c91c5e77936a` | `### Senior Design I (ECE 460) — Dr. Sammoud (mentor) {toggle="true" color="orange"}` | orange |
| `3c9c25483c8381b8aa9cdb742c9fbb57` | `### RevEng — Malware Analysis (ECE 497) — Dr. Stamm {toggle="true" color="blue"}` | blue |
| `3d5c25483c83812e9f90c26edde306f4` | `### Science Fiction (ENGL H237) — Prof. Power {toggle="true" color="purple"}` | purple |
| `3cac25483c8381a68916edd6d33f712c` | `### Deep Learning (CSSE 416) — Dr. Boutell {toggle="true" color="green"}` | green |

(If a heading's wording has drifted, match on the course name prefix — e.g. "Senior
Design", "RevEng", "Science Fiction", "Deep Learning" — not the whole string.)

## Steps

### 1. Pull upcoming items from the database

```sql
SELECT Title, Type, Course,
       "date:Due Date:start"      AS due,
       "date:Due Date:is_datetime" AS timed
FROM "collection://db16daa8-1c51-43cb-951c-c59ed5d551fc"
WHERE Status != 'Done'
  AND "date:Due Date:start" >= '<TODAY as YYYY-MM-DD>'
ORDER BY Course, due ASC;
```

`"date:Due Date:start"` comes back either `YYYY-MM-DD` (date-only, `timed=0`) or
`YYYY-MM-DD HH:MM:SSZ` in **UTC** (`timed=1`). For timed rows convert UTC → US
Eastern for display: subtract 4h during EDT (through 2026-11-01), 5h during EST
(from 2026-11-02). Date-only rows have no time.

### 2. Pick the lines per course

For each of the 4 courses, take its rows in due-date order and keep:

- the **next 3**, **plus** any extra row due within **7 days of today**, capped at
  **5** lines total.

Format each as a checkbox line, indented one tab:

```
	- [ ] <clean title> — due <Ddd Mon D>[, <h:mm AM/PM> ET]
```

- **Clean title:** strip a leading course prefix if present (`SciFi — `,
  `DL — `, `RevEng — `, `Senior Design — `). Keep the rest verbatim.
- Date-only row → `— due Wed Sep 10`. Timed row → `— due Wed Sep 10, 11:00 PM ET`.
- An item whose due date is **today** → use `— today, <Ddd Mon D>` (plus time if timed).
- If a course has **no** qualifying rows: single line `	- [ ] _(nothing upcoming in the database)_`

### 3. Fetch the page and rewrite each block

`mcp__claude_ai_Notion__notion-fetch` on `2bdc2548-3c83-8073-a49d-d49b7cd3aa1f`.

Inside each course toggle the current block looks like:

```
	<span color="gray">— next up (from database) —</span>
	- [ ] …
	- [ ] …
```

It runs from the `<span color="gray">— next up (from database) —</span>` line to the
last `- [ ] ` / `- [x] ` line **before the next `###` heading** (for Deep Learning,
before the `<empty-block/>` that precedes the Courses database). The non-dated
`- [x]` / `- [ ]` lines **above** the marker are Rohan's one-time items — leave them
untouched.

Use `notion-update-page` `command: "update_content"` with one `content_updates`
entry per course:

- **old_str** = the exact current block for that course (marker line + every
  checkbox line under it, copied verbatim from the fetch, including leading tabs and
  newlines).
- **new_str** = `\t<span color="gray">— next up (from database) —</span>` followed by
  the freshly built checkbox lines from step 2.

If a toggle has **no** marker line yet (someone deleted it): set old_str to that
toggle's last existing `- [ ]` / `- [x]` line and new_str to that same line + `\n` +
the new block.

Do all 4 in a single `update_content` call when you can. Keep every edit inside the
four toggles — change nothing else.

### 4. Report

Print a short summary — per course, the lines now shown (or "nothing upcoming").
Note if a course heading couldn't be matched. No log file, no Discord — this is a
fast interactive/`-p` refresh, not a pipeline.

## Boundaries

- Page body only. The database and its views are read-only here.
- Coursework only — the four courses above. A course with no matching toggle → say so
  in the report, don't create anything.
- Don't reconcile, don't dedupe against Todoist, don't mark anything Done.
