---
name: coursework-sync
description: On-demand pipeline that refreshes the Notion Homework Tracker from Outlook + Moodle + the CSSE416 calendar sheet, so the user never has to open those apps. Manual trigger only ("/coursework-sync", "sync coursework", "refresh the tracker", or a `claude -p` run). NOT part of email triage.
---

# Coursework Sync

## What this is

A single-pass, **user-triggered** sync that pulls every coursework signal from the
sources below and reconciles them into the Notion **Homework Tracker**, then reports
what changed. It exists so the user doesn't have to touch Outlook, Moodle, or Notion
by hand.

- **Not** triggered by session start or greetings. Not part of `daily-triage` /
  `act-on-triage` (those are inbox-wide and email-shaped; this is coursework-only and
  reads Moodle too).
- Designed to run on a **small model (Haiku)** — the steps below are explicit so no
  judgement calls are needed. Follow them in order; don't improvise.
- Safe to run repeatedly. Reconciliation by `Source` key makes re-runs idempotent.

Invocation examples:
- Interactive: `/coursework-sync`
- Terminal (cheap, unattended-ish):
  `claude -p "Run skills/coursework-sync/SKILL.md" --model claude-haiku-4-5-20251001`

## Autonomy (fixed for this skill — do not widen)

| Allowed, no asking | Never |
|---|---|
| Create new Assignments & Exams rows | Set any row's Status to **Done** |
| Update an existing row's **Due Date** when a source shows a changed date | Delete or archive any row |
| Update a row's Title/Type/Weight when a source clarifies it | Touch the Courses database |
| Refresh the "Upcoming (2 wks)" view's date cutoff (view config, not a row) | Change any other view's filter/sort |
| Append to the sync log; send the Discord change-ping (see Reporting) | Send email; mark email read; edit Moodle; write anywhere outside the Homework Tracker |

Marking things done is the user's job. This skill only keeps the *list* and the
*dates* current.

## Sources & how to read them

Run all three. If one is unreachable, do the others and note the gap in the report —
never abort the whole run.

### 1. Outlook (professor / Moodle / Gradescope mail) — `bin/outlook-scan.sh`

Run `Bash: /Users/mrohan/Documents/my-agent/bin/outlook-scan.sh 10` — a **fixed,
already-tested script**, not something to compose inline. It uses a
`whose time received > cutoff` filter (fast, lets Outlook do the filtering
server-side — confirmed ~100 messages in <20s) and returns one block per message:
```
---MSG--- <id>|<time received>|<sender address>|<subject>
<plain text body>
---END---
```
Parse that text. Do not write your own AppleScript for this step — a from-scratch
script is what timed out in testing (2026-09-04, Haiku run) even though the fixed
script above is fast; always call the file. If the script itself errors (not just
"no messages"), report Outlook as skipped with the error, don't retry with a
different approach.

Keep a message if any is true:
- sender domain is `rose-hulman.edu` or `gradescope.com`
- sender name/address contains: `stamm`, `brooks`, `sammoud`, `terlep`, `walter`,
  `minster`, `boutell`, `petrik`, `shibberu`
- subject contains: `moodle`, `assignment`, `homework`, `due`, `exam`, `quiz`,
  `lab`, `reading`, `project`, `MP`, a course code (`ECE`, `CSSE`, `MA`, `ENGL`),
  or a course nickname (`deep learning`, `malware`, `reverse eng`, `romanticism`,
  `senior design`)

For each kept message pull `subject`, `address of sender`, `time received`,
`plain text content`, and `id`. Extract any assignment/exam/reading and its due
date. The Outlook message `id` is the `Source` key: `outlook:<id>`.

### 2. Moodle — calendars **and** course content — `claude-in-chrome` ONLY

**Do not use `curl`, `WebFetch`, or any non-browser tool for Moodle** — it requires
the logged-in session cookie that only lives inside Chrome via the
`mcp__claude-in-chrome__*` tools (`tabs_context_mcp` → `navigate` → `get_page_text`).
A `curl`/`WebFetch` request to a Moodle URL will always look like "not logged in"
regardless of the real session state — that result is meaningless and must not be
reported as "Moodle skipped: not logged in." If the browser tools aren't available,
say so explicitly in the report instead of substituting another tool.

Calendars alone under-report: RevEng/Romanticism/Senior Design post deliverables as
course content (weekly sections, a syllabus, a scheduled "Draft Schedule" PDF) that
never makes it onto the Moodle calendar block. Scan both. One tab, reused across all
of this.

**2a. Calendars** — for each course id, load current + next month:
`https://moodle.rose-hulman.edu/calendar/view.php?view=month&course=<id>` then append
`&time=<unix ts of first day of next month>` for the second. Each event → title +
date, `Source` key `moodle:<courseid>-<slugified title>`. No reliable time on these →
store date-only.

**2b. Course content** — open `https://moodle.rose-hulman.edu/course/view.php?id=<id>`,
click "Open all topics"/"Open all" if present, `get_page_text`. Look for graded
deliverables (quizzes, reflections, MPs, tests, essays, homeworks) with a stated due
day. If the course links a **syllabus/schedule file** (PDF, docx, xlsx) that carries
the actual date grid — Romanticism's "Draft Schedule", RevEng's syllabus — open the
resource link; if it renders as an inline PDF with no extractable text, navigate to
the same `pluginfile.php` URL with `?forcedownload=1` appended to force it into
`~/Downloads/`, then read the downloaded file directly (`Read` handles PDF/docx).
Only re-parse a schedule file if its Moodle-reported modified date is newer than the
last sync (skip re-downloading an unchanged one — check the log). `Source` key:
`moodle:<courseid>-schedule-<slugified item>` (e.g. `moodle:124416-schedule-quiz1`).

| Course | Moodle id | Notion Course URL |
|---|---|---|
| Deep Learning (CSSE416) | `124332` | `https://app.notion.com/p/3cac25483c8381a68916edd6d33f712c` |
| RevEng / Malware Analysis (ECE497) | `124443` | `https://app.notion.com/p/3c9c25483c8381b8aa9cdb742c9fbb57` |
| Senior Design I (ECE460) | `125529` | `https://app.notion.com/p/3c9c25483c8381cc80f4c91c5e77936a` (also check `124740`, the combined Master Senior Design course, for pre-team-assignment deliverables like the Syllabus Quiz) |
| Romanticism (ENGLH337) | `124416` | `https://app.notion.com/p/3cac25483c83815f9b73f3c0bb6231b8` |

If the first page load lands on `login/index.php` ("session has timed out"):
**stop the entire Moodle step (2a and 2b)**, put one line in the report — "Moodle
skipped: not logged in. Open moodle.rose-hulman.edu, sign in with Rose SSO, then
re-run." — and continue with the other sources. Do not attempt to log in.

Weekly-topic sections with no content yet (e.g. RevEng Wk 2–10 before that week
arrives) are normal — don't report them as a gap, just nothing to extract yet.

### 3. CSSE416 course calendar — Google Drive MCP

`mcp__claude_ai_Google_Drive__read_file_content` with
`fileId: 1uOxtHLsbPy1WAp-yOryfO4jxuiQVtRiwBAlUTKIQ7nk`. This is the authoritative DL
schedule (H1–H9, Q1–Q5, Tests, project milestones). Homeworks/Lessons are due
**11:00 PM ET**; status reports / slides due **3:00 PM ET**; quizzes & tests are
in-class (store date-only). Skip the vague weekly "Due: Random Lesson" entries and
uncollected examples/demos. `Source` key: `gsheet:416-<item>` (e.g. `gsheet:416-H3`).

## Reconcile → write (per `~/.claude/skills/homework-tracker/SKILL.md`)

1. `mcp__claude_ai_Notion__notion-query-data-sources` on
   `collection://db16daa8-1c51-43cb-951c-c59ed5d551fc` — pull all rows once.
2. For each source item:
   - **Match on `Source` key.** Found → if the due date (or title/type) differs,
     `notion-update-page` those fields. Same → do nothing.
   - No key match → fuzzy match (same Course + similar Title + Due Date within 2
     days). Hit → update that row and also set its `Source`. Miss → it's new.
   - **New** → `notion-create-pages` into
     `data_source_id: db16daa8-1c51-43cb-951c-c59ed5d551fc` with `Title`, `Type`
     (Assignment/Exam/Reading/Quiz/Project/Preparation), `Status: "Not started"`,
     `Due Date` (ET; `date:Due Date:is_datetime` must be `0` or `1` as a number, and
     for timed items pass an offset e.g. `2026-09-17T23:00:00-04:00` — EDT is
     `-04:00`, EST from Nov 1 2026 is `-05:00`), `Course` (relation URL above),
     `Source`.
3. **Never** change `Status`, never delete. If a tracked row's date is *earlier* than
   today and no source still references it, leave it — the user decides.
4. Page body: dated items never go here (see `homework-tracker` SKILL.md — the
   Upcoming view is the near-term surface now). Only touch a toggle if you found a
   genuinely non-dated action item (e.g. "waiting on X's reply").
5. **Refresh the rolling "Upcoming (2 wks)" view — every run, even if nothing else
   changed:** `notion-update-view` on `view://3d1c2548-3c83-8197-a6f2-000c773383bd`
   with `configure: 'CLEAR FILTER; FILTER "Due Date" <= "<today + 14 days, ISO>" AND
   "Status" != "Done"; SORT BY "Due Date" ASC'`. This is what makes items "unhide as
   weeks progress" — the filter is a static date, not a live relative one (the
   connector doesn't support `NOW()+Nd` or filtering on formula properties), so it
   only advances when this skill runs. Note the new cutoff in the log line.

## Reporting

1. **Always** append one entry to `/Users/mrohan/Documents/my-agent/logs/coursework-sync.log`
   (create the `logs/` dir if missing):
   ```
   [YYYY-MM-DD HH:MM] sources: outlook=ok moodle=ok|skipped gsheet=ok
   upcoming-view cutoff -> <new date>
   + added:   <course> · <title> · <type> · <due>
   ~ updated: <course> · <title> · <old due> -> <new due>
   (no changes)   <- if nothing added/updated (the cutoff still refreshes regardless)
   ```
2. **If (and only if) something was added or updated**, and the Discord MCP is
   connected (`agent.md` Tools table), send **one** message to the user summarising
   the same `+`/`~` lines. This ping is pre-authorised by the user *for this skill's
   change summary only* (chosen 2026-09-03) — it is not a general lift of
   `agent.md` Hard Rule 4. If Discord is not connected, the log + the run's own
   stdout is the report; do not fall back to email.
3. Print the same summary to stdout so a `claude -p` run surfaces it.

## Boundaries

- Coursework only. Club/team/committee meetings → `class_schedule_fall_2026_27`
  memory + Google Calendar, never the tracker.
- If a course appears that isn't one of the four above, list it in the report and
  stop — don't invent a Courses row.
- Don't reconcile against Todoist here; that's `act-on-triage`'s job for P0 nudges.
- One Chrome tab, closed at the end; the tab group must be gone before the run ends.
