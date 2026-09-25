---
name: calendar-organize
description: Use right after skills/daily-triage/SKILL.md finishes at session start, or any time the user asks to plan/organize their day or calendar ("organize my day", "plan my day", "organize my calendar", "/calendar-organize").
---

# Calendar Organize

## Overview

Turns a stated list of today's priorities into real, timed Google Calendar blocks, built around whatever's already fixed on the calendar (classes, recurring meetings, recurring personal blocks like Exercise). It asks what's on the agenda, checks the actual current time, then creates one event per task block from now through the rest of the day — not just a chat summary.

## When to Use / When Not To

- Runs right after `skills/daily-triage/SKILL.md`'s digest (and any `act-on-triage` follow-up) at session start.
- Also fires on direct invocation any time: "/calendar-organize", "organize my day", "plan my day", "organize my calendar", "refresh my schedule."
- If the triggering message already states today's priorities (e.g. "organize my day: 1. X 2. Y"), skip the extra question and go straight to building blocks.
- Does **not** replace `tracker-nextup` (Notion coursework checklist) or `daily-triage` (email digest) — this is purely about turning a stated task list into calendar time.
- Does **not** invent tasks. Every block must trace back to something Rohan actually said this run.

## Pre-flight

1. **Check the actual current time** (`TZ=America/New_York date` or equivalent) before building anything — never assume the day starts fresh. See [[feedback_check_current_time_before_scheduling]]. Only plan from now forward; don't relitigate hours already passed.
2. **Pull today's existing calendar events** (`list_events`, today 00:00–23:59 in Rohan's current timezone) to find fixed commitments — classes, recurring meetings, recurring personal blocks (e.g. Exercise, Client Meeting). Never propose a block that overlaps one of these, and never recreate or duplicate them.
3. If today's day-of-week has known recurring commitments not yet reflected on the calendar (check `class_schedule_fall_2026_27.md` / relevant memory), flag the gap rather than silently guessing.

## Steps

1. Ask what Rohan is doing today, unless already stated in the triggering message. Accept any format — priority tiers, flat list, whatever he gives.
2. Build a block per task, working only from "now" to end of day, slotted around the fixed events from Pre-flight step 2. Size blocks to the task, not a rigid grid — "every hour of the day" means the day is fully accounted for, not that every block is exactly 60 minutes.
3. Create each block as a real event via `create_event` (not just a chat summary). Tag every event this skill creates with a marker in the description, e.g. `[calendar-organize 2026-09-21]`, so a same-day re-run can find and replace its own prior blocks instead of duplicating them.
4. On a same-day re-run: `list_events` for today, delete any event carrying this skill's marker for today's date, then rebuild from the current "now" forward. Never delete an event without the marker — that's not this skill's to touch.
5. Color-code by category using the palette below, reusing whatever color a fixed event already has (don't recolor classes/meetings/Exercise).
6. Report back: the list of blocks created, with times — not the whole plan re-typed as prose.

## Quick Reference — color palette

| Category | colorId | Name |
|---|---|---|
| Main-priority task block | 9 | Blueberry |
| Med-priority task block | 5 | Banana |
| Buffer / break | 8 | Graphite |
| Fixed commitments (classes, standing meetings, Exercise) | *(leave as-is)* | — |

## Common Mistakes

| Mistake | Fix |
|---|---|
| Building the plan starting at wake-up time regardless of when it's actually invoked | Always pull current time first (Pre-flight 1) — plan only from now forward. |
| Proposing a block that overlaps a class, standing meeting, or Exercise | Always `list_events` for today before drafting any block (Pre-flight 2). |
| Re-running mid-day and ending up with duplicate blocks | Tag every created event; on re-run, delete same-day tagged events before rebuilding (Steps 3–4). |
| Recreating a recurring fixed commitment (e.g. Exercise, Client Meeting) as a new one-off event | Those already exist on the calendar — this skill only manages the day's freeform task blocks, never the standing ones. |

## Hard Constraints

- Only ever create, update, or delete events this skill itself tagged (`[calendar-organize <date>]` marker) — never touch an event without that marker.
- Never schedule a block before the actual current time.
- Calendar create/update/delete for these day-of task blocks is autonomous per `agent.md`/CLAUDE.md's "act, then report" mode — no per-block confirmation needed, but always report what was created.
